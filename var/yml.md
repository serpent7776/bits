# YML: a simplified successor to XML

## Overview

YML keeps the part of XML everyone uses (elements, attributes, text, comments) and removes everything else. It looks like XML, so people and language models can read and write it with no training, and a complete parser, with a JSON exporter and a writer, is about 250 lines of Python.

**Design goals**

- **Familiar.** Angle-bracket tags, `name="value"` attributes and `&amp;`-style escapes work as they do in XML and HTML.
- **One way to do each thing.** One quote style, one comment form, one raw-text form, a fixed set of five escapes.
- **Fast to parse.** Every syntax character is ASCII, so parsers work on UTF-8 bytes directly. Parsing is a single pass with at most 4 bytes of lookahead and no tables to load.
- **Safe by construction.** Nothing in a document can fetch a file, reach the network or expand into more output than its input.
- **Agent-friendly.** Strict errors with line and column, no implicit typing, and a fixed mapping to JSON so tools can check output mechanically.

**Non-goals:** schemas, data types, namespaces, includes, styling and querying. Those belong in separate, optional specs layered on top.

## YML at a glance

A YML document is one root element. This example uses every feature in the language:

```xml
<!-- library.ym -->
<library owner="city" updated="2026-11-11">
  <book id="b1" lang="en">
    <title>The Hobbit</title>
    <author>J. R. R. Tolkien</>
    <tags><tag>fantasy</><tag>classic</></tags>
    <cover src="hobbit.png"/>
  </book>

  <note>
    Opening hours change in <b>December</b>.
    Ask at the desk for R&amp;D titles.
  </note>

  <snippet lang="c"><[[
if (a < b && c > 0) { return x[i]; }
]]></snippet>
</library>
```

What it shows:

- `</>` closes the innermost open element. `</author>` would mean the same; use the named form when the opening tag is far away.
- `<cover .../>` is an element with no content.
- Indentation and line breaks between tags are not part of the data. The text of `note` starts at "Opening" and ends at "titles."
- `<[[ ... ]]>` holds raw text: nothing inside it is escaped, so code and markup can be pasted as is.

The parser turns it into this JSON (the `book` element shown, others abbreviated):

```json
{"name": "library", "attrs": {"owner": "city", "updated": "2026-11-11"}, "children": [
  {"name": "book", "attrs": {"id": "b1", "lang": "en"}, "children": [
    {"name": "title", "attrs": {}, "children": ["The Hobbit"]},
    {"name": "author", "attrs": {}, "children": ["J. R. R. Tolkien"]},
    {"name": "tags", "attrs": {}, "children": [ ... ]},
    {"name": "cover", "attrs": {"src": "hobbit.png"}, "children": []}]},
  {"name": "note", "attrs": {}, "children": ["Opening hours change in ", {"name": "b", ...}, ".\n    Ask at the desk for R&D titles."]},
  {"name": "snippet", "attrs": {"lang": "c"}, "children": ["if (a < b && c > 0) { return x[i]; }\n"]}]}
```

## What changes from XML

YML removes every XML feature that needs a lookup table, a second pass, or network access, plus every feature with two ways of saying the same thing.

| XML feature | In YML | Why |
| --- | --- | --- |
| Elements, attributes, text, comments | Kept | The core everyone uses |
| `</name>` end tags | Kept, plus `</>` | Shorter to write; named form still checks nesting |
| `<![CDATA[ ... ]]>` | Replaced by `<[[ ... ]]>` | Shorter, and extendable to `<[[[ ... ]]]>` so any text fits |
| Five predefined entities, `&#...;` | Kept, fixed set | Already known to every author and model |
| DTDs and user-defined entities | Removed | Source of XXE and "billion laughs" attacks; schemas belong outside the document |
| Namespaces (`xmlns`) | Removed; `:` allowed in names | Most contested XML feature; `svg:rect` stays a plain name |
| `<?xml ...?>` declaration, encoding choice | Removed | UTF-8 only |
| Processing instructions `<?...?>` | Removed | Rarely used; an element does the same job |
| `'single'` quoted attributes | Removed | One quote style |
| Attribute-value normalisation | Removed | Values are kept exactly as written, line breaks included |
| `xml:space`, `xml:lang`, `xml:id` | Removed | No special attribute names |
| Unicode name characters | ASCII only | Fast byte-level scanning, no Unicode tables |
| Text outside the root | Still an error | One root keeps the model simple |

## Syntax reference

The whole language is six constructs: elements, attributes, text, escapes, raw blocks and comments.

### Characters and files

- Files are UTF-8. A leading byte-order mark is ignored.
- CR LF and lone CR become LF before parsing.
- Control characters other than tab and line feed are errors, as are U+FFFE and U+FFFF. This matches XML 1.0, so every YML document converts to XML.
- Proposed file extension `.ym` (see the naming note).

### Names

Element and attribute names match `[A-Za-z_][A-Za-z0-9_.:-]*` and are case-sensitive. The colon has no special meaning.

### Elements

| Form | Meaning |
| --- | --- |
| `<name>` ... `</name>` | Element with content; the end name must match |
| `<name>` ... `</>` | Same; closes the innermost open element |
| `<name/>` | Element with no content |

Whitespace is allowed before `>` and `/>`, and between attributes. It is not allowed after `<` or `</`, and `</>` has no spaces.

### Attributes

- Written `name="value"`. Double quotes only; no spaces around `=`.
- Every attribute has a value. Write `disabled=""` or `disabled="true"`, not bare `disabled`.
- Names are unique within an element. Order is kept.
- Values are strings, kept exactly as written after escapes are decoded. Line breaks and tabs are preserved.

### Text and escapes

In text, `<` and `&` must be escaped. In attribute values, `"` and `&` must be escaped. Nothing else is ever required.

| Escape | Character |
| --- | --- |
| `&lt;` | `<` |
| `&gt;` | `>` |
| `&amp;` | `&` |
| `&quot;` | `"` |
| `&apos;` | `'` |
| `&#65;` or `&#x41;` | Any character allowed in a file, plus carriage return (\&#13;) |

There are no other named escapes: `&nbsp;` is an error. Write the character itself instead.

### Raw blocks

`<[[` starts a raw block and `]]>` ends it. Everything between is literal text: no escapes, tags or comments are recognised.

- If the text contains `]]>`, add brackets to the fence: `<[[[` ... `]]]>`. Any number of brackets from two upward works; the closing fence uses the same number.
- One line feed directly after the opening fence is dropped, so a block can start on its own line.
- A raw block is ordinary text in the data model. It joins any text next to it.

### Comments

`<!-- ... -->` may appear anywhere text may, and before or after the root element. A comment ends at the first `-->`, and `--` inside it is allowed. Comments do not nest and are not part of the data: text on both sides of a comment joins up.

### Whitespace

Two rules separate layout from content. They apply only to whitespace typed literally in ordinary text, never to raw blocks or to characters written as escapes.

1. **Layout between tags is dropped.** A stretch of text between two tags or raw blocks that is only spaces, tabs and line breaks, and contains at least one line break, is removed.
2. **Content edges are trimmed.** At the start and end of an element's content, a run of whitespace that contains a line break is removed.

All other whitespace is kept exactly, including line breaks inside a paragraph of text. Rendering choices, such as collapsing spaces, belong to the application.

One consequence: `<b>a</b>` followed by a line break and `<i>b</i>` produces no space between them. In prose, keep the space on the same line, or end the line with text.

To keep whitespace that the rules would remove, write it as an escape: `&#10;` for a line break, `&#32;` for a space.

### Document

A document is optional comments and whitespace, exactly one root element, then optional comments and whitespace. Any other text outside the root is an error.

## Data model

A parsed document is a tree of two node types, and every conforming parser must produce the same tree for the same input.

- **Element:** a name, an ordered map of attribute names to string values, and an ordered list of children.
- **Text:** a non-empty string. Adjacent text, including raw blocks and text on both sides of a comment, is always merged, so two text nodes are never siblings.

Comments, the choice of `</name>` versus `</>`, and escape spelling are not part of the model.

There are no types. `count="3"` is the string `"3"`; deciding that it is a number is the job of the application or a schema. This avoids YAML-style surprises where `no` silently becomes `false`.

### Canonical JSON form

Every tree has one JSON form, used for test suites and for checking agent output:

```json
{"name": "a", "attrs": {"x": "1"}, "children": ["text", {"name": "b", "attrs": {}, "children": []}]}
```

An element is an object with exactly the keys `name`, `attrs` and `children`, and a text node is a JSON string. All three keys are always present, even when empty.

## Grammar

The complete grammar is 16 rules. A parser decides what comes next from at most three bytes after `<`.

```
document  = [ BOM ] misc* element misc* ;
misc      = ws | comment ;

element   = "<" name attrs [ ws ] ( "/>" | ">" content endtag ) ;
attrs     = ( ws name "=" '"' attvalue '"' )* ;
endtag    = "</>" | "</" name [ ws ] ">" ;     (* name must equal the start tag's *)

content   = ( chardata | ref | element | raw | comment )* ;
chardata  = ( char - ( "<" | "&" ) )+ ;
attvalue  = ( char - ( '"' | "&" ) | ref )* ;
ref       = "&" ( "lt" | "gt" | "amp" | "quot" | "apos"
               | "#" digit+ | "#x" hexdigit+ ) ";" ;

raw       = "<" "["{n} rawtext "]"{n} ">" ;   (* n >= 2, same n on both sides;
                                                rawtext is the shortest match *)
comment   = "<!--" commenttext "-->" ;          (* commenttext is the shortest match *)

name      = namestart namechar* ;
namestart = "A"-"Z" | "a"-"z" | "_" ;
namechar  = namestart | "0"-"9" | "." | "-" | ":" ;
ws        = ( " " | TAB | LF )+ ;
char      = any Unicode scalar value except U+0000-U+0008, U+000B-U+001F,
            U+FFFE and U+FFFF ;   (* references may also produce U+000D *)
```

### Dispatch on `<` inside content

| Next bytes | Construct |
| --- | --- |
| `/` | End tag |
| `!--` | Comment |
| `[[` | Raw block |
| `A`-`Z`, `a`-`z`, `_` | Start tag |
| Anything else | Error: write `&lt;` |

### Why it is fast

- **Bytes, not characters.** Every delimiter is ASCII, and UTF-8 never reuses ASCII bytes inside multi-byte sequences. A parser can scan bytes and copy text spans without decoding them.
- **No state beyond a stack.** There is no entity table, no DTD and no namespace scope. Memory is the stack of open element names plus the current text run.
- **Fast skipping.** Text runs end only at `<` or `&`, comments at `-->`, and raw blocks at their fence. These are single `memchr`-style searches, which vectorise well.
- **Streams naturally.** Start, text and end events can be emitted as they are read, SAX-style. The whitespace rules need to look back over at most one pending text run.

## Errors and security

Any error stops parsing; a parser never guesses what a broken document meant. Two parsers therefore never disagree about a document, and an agent gets a precise message it can act on.

### Error reporting

Errors report line and column (1-based, counted in characters) and say what to write instead. From the reference parser:

```
library.ym:3:3: </c> does not match <b>
library.ym:1:4: '<' must be escaped as &lt; in text
library.ym:1:4: unknown reference &nbsp;
library.ym:1:10: duplicate attribute 'x'
```

### Security properties

- **No external access.** Nothing in the syntax refers to a file, URL or other document, so XXE-style attacks cannot be written.
- **Linear output.** Without user-defined entities, the parsed tree is never larger than the input. "Billion laughs" expansion is impossible.
- **No ambiguity.** One parse per input, so a validator and a consumer cannot be tricked into reading different trees.

### Recommended limits

Parsers should let callers set limits and should ship with these defaults:

| Limit | Default |
| --- | --- |
| Nesting depth | 512 |
| Attributes per element | 1,024 |
| Document size | Set by the caller |

## Converting to and from XML

YML to XML is lossless. XML to YML is lossless for typical data and documents, and loses only DTD-driven features and processing instructions.

### XML to YML

1. Parse the XML with a standard parser, expanding entities and applying DTD defaults.
2. Drop the declaration and DOCTYPE. Turn processing instructions into elements (`<?pi data?>` to `<pi>data</pi>`) or drop them.
3. Keep prefixed names as written. Keep `xmlns` and `xmlns:p` as ordinary attributes, so the namespace information survives for tools that want it.
4. Write CDATA sections as raw blocks.
5. Write text that the whitespace rules would trim with `&#10;` escapes where it matters, such as in `<pre>` content.
6. Rename any name with characters outside the ASCII name set, or escape it to a convention such as `_x00E9_`.

### YML to XML

1. Write every `</>` as its named end tag.
2. Write raw blocks as escaped text, or as CDATA, splitting at any `]]>`.
3. In attribute values, write tab and line feed as `&#9;` and `&#10;`. XML parsers would otherwise turn them into spaces.
4. Output the parsed tree; the whitespace rules have already been applied.

The result is well-formed XML 1.0 that any XML parser accepts. A name like `svg:rect` needs a matching `xmlns:svg` attribute only if the consumer is namespace-aware.

## Naming note and open questions

The name needs a decision before anything is published: `.yml` is already the standard extension for YAML, so editors, GitHub and CI tools would treat YML files as YAML. This draft uses `.ym` instead.

Open questions:

1. **Name.** Keep "YML" with the `.ym` extension, or pick a name that cannot be confused with YAML in search and conversation?
2. **Line breaks between inline elements.** They are currently dropped. The alternative is turning them into one space, which helps prose but breaks pretty-printed data.
3. **Multiple root elements.** Allowing a sequence of roots would let logs be appended to without rewriting the file, at the cost of the one-root rule.
4. **`</>` in long files.** A style rule, not a syntax rule, could ask linters to require named end tags when the open tag is more than about 20 lines away.
5. **Versioning.** There is no version marker. Any future incompatible change would need a new extension.

A reference parser in Python (`yml.py`, about 250 lines) and its test suite (`test_yml.py`, including 3,000 randomised write-then-read round trips) accompany this draft.
