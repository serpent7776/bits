datatype seconds = Seconds of real

structure XY = struct
  type t = {x: real, y: real}

  val zero = {x=0.0, y=0.0}

  fun new{x, y} = {x=x, y=y}

  fun mul({x, y}, Seconds dt) = {
    x = x * dt,
    y = y * dt
    }

  fun add(l:t, r:t) = {
    x = #x l + #x r,
    y = #y l + #y r
    }

  infix * +
  val op* = mul
  val op+ = add
end

structure A2 = struct
  datatype t = A2 of XY.t

  val zero = A2 {x=0.0, y=0.0}

  fun new{x, y} = A2 {x=x, y=y}
end

structure V2 = struct
  datatype t = V2 of XY.t

  val zero = V2 {x=0.0, y=0.0}

  fun new{x, y} = V2 {x=x, y=y}
  fun upd(V2 v, A2.A2 a, dt) =
    let open XY in
      V2 (v + a * dt)
    end
end

structure P2 = struct
  datatype t = P2 of XY.t

  val zero = P2 {x=0.0, y=0.0}

  fun new{x, y} = P2 {x=x, y=y}
  fun upd(P2 p, V2.V2 v, dt) =
    let open XY in
      P2 (p + v * dt)
    end
end

structure Res = struct
  type t = {
    cur: int,
    min: int,
    max: int
  }

  val IntMax = Option.getOpt(Int.maxInt, 2147483647)

  fun sub({cur, min, max}, x) =
    {min=min, max=max, cur=cur - Int.min(cur, x)}
  fun add({cur, min, max}, x) =
    {min=min, max=max, cur=cur + Int.min(IntMax - cur, x)}
end

structure Hp = struct
  datatype t = Hp of Res.t

  fun new{min, max} = Hp {cur=max, min=min, max=max}
  fun sub(Hp hp, x) = Hp (Res.sub(hp, x))
  fun add(Hp hp, x) = Hp (Res.add(hp, x))
end

structure Mp = struct
  datatype t = Mp of Res.t

  fun new{min, max} = Mp {cur=max, min=min, max=max}
  fun sub(Mp hp, x) = Mp (Res.sub(hp, x))
  fun add(Mp hp, x) = Mp (Res.add(hp, x))
end

structure Lives = struct
  datatype t = Lives of Res.t

  fun new{min, max} = Lives {cur=max, min=min, max=max}
  fun sub(Lives lives, x) = Lives (Res.sub(lives, x))
  fun add(Lives lives, x) = Lives (Res.add(lives, x))
end

structure Being = struct
  type t = {
    hp: Hp.t,
    mp: Mp.t,
    p: P2.t,
    v: V2.t,
    a: A2.t
    }

  fun upd(e:t, dt) = {
    hp = #hp e,
    mp = #mp e,
    p = P2.upd(#p e, #v e, dt),
    v = V2.upd(#v e, #a e, dt),
    a = #a e
    }
end

structure Player = struct
  datatype t = Player of {
    name: string,
    lives: Lives.t,
    be: Being.t
    }

  fun new{name, x, y} = Player {
    name = name,
    lives = Lives.new{min=0, max=3},
    be = {
      hp = Hp.new{min=0, max=100},
      mp = Mp.new{min=0, max=100},
      p = P2.new{x=x, y=y},
      v = V2.zero,
      a = A2.zero
      }
    }

  fun upd(Player p, dt) = Player {
    name = #name p,
    lives = #lives p,
    be = {
      hp = #hp (#be p),
      mp = #mp (#be p),
      p = P2.upd(#p (#be p), #v (#be p), dt),
      v = V2.upd(#v (#be p), #a (#be p), dt),
      a = #a (#be p)
      }
    }
end

structure Goblin = struct
  datatype t = Goblin of Being.t

  fun new{x, y} = Goblin {
    hp = Hp.new{min=0, max=50},
    mp = Mp.new{min=0, max=10},
    p = P2.new{x=x, y=y},
    v = V2.zero,
    a = A2.zero
    }

  fun upd(Goblin g, dt) = Goblin (Being.upd(g, dt))
end

fun loop(player, goblin, dt) =
  let
    val player = Player.upd(player, dt)
    val goblin = Goblin.upd(goblin, dt)
  in
    loop(player, goblin, dt)
  end

fun main () =
  let
    val player = Player.new({name="Joe", x=0.0, y=0.0})
    val goblin = Goblin.new({x=10.0, y=10.0})
    val dt = Seconds 0.50
  in
    loop(player, goblin, dt)
  end
