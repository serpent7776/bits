type seconds = Seconds of float

module XY = struct
        type t = {x: float; y: float}

        let zero = {x=0.0; y=0.0}

        let make {x; y} = {x; y}

        let mul {x;  y} (Seconds dt) = {
                x = x *. dt;
                y = y *. dt;
        }

        let add l r = {
                x = l.x +. r.x;
                y = l.y +. r.y;
        }

        let ( + ) = add
        let ( * ) = mul
end

module A2 = struct
        type t = A2 of XY.t

        let zero = A2 {x=0.0; y=0.0}

        let make xy = A2 xy
end

module V2 = struct
        type t = V2 of XY.t

        let zero = V2 {x=0.0; y=0.0}

        let make xy = V2 xy

        let upd (V2 v) (A2.A2 a) dt =
                V2 XY.(v + a * dt)
end

module P2 = struct
        type t = P2 of XY.t

        let zero = P2 {x=0.0; y=0.0}

        let make xy = P2 xy

        let upd (P2 p) (V2.V2 v) dt =
                P2 XY.(p + v * dt)
end

module Res = struct
        type t = {
                cur: int;
                min: int;
                max: int;
        }

        let sub r x = {r with cur = r.cur - (min r.cur x)}
        let add r x = {r with cur = r.cur + (min (Int.max_int - r.cur) x)}
end

module Hp = struct
        type t = Hp of Res.t

        let make min max = Hp {cur=max; min=min; max=max}
        let sub (Hp hp) x = Hp (Res.sub hp x)
        let add (Hp hp) x = Hp (Res.add hp x)
end

module Mp = struct
        type t = Mp of Res.t

        let make min max = Mp {cur=max; min=min; max=max}
        let sub (Mp mp) x = Mp (Res.sub mp x)
        let add (Mp mp) x = Mp (Res.add mp x)
end

module Lives = struct
        type t = Lives of Res.t

        let make min max = Lives {cur=max; min=min; max=max}
        let sub (Lives lives) x = Lives (Res.sub lives x)
        let add (Lives lives) x = Lives (Res.add lives x)
end

module Being = struct
        type t = {
                hp: Hp.t;
                mp: Mp.t;
                p: P2.t;
                v: V2.t;
                a: A2.t;
        }

        let upd e dt = {
                e with
                p = P2.upd e.p e.v dt;
                v = V2.upd e.v e.a dt;
        }
end

module Player = struct
        type t = Player of {
                name: string;
                lives: Lives.t;
                be: Being.t;
        }

        let make name xy = Player {
                name = name;
                lives = Lives.make 0 3;
                be = {
                        hp = Hp.make 0 100;
                        mp = Mp.make 0 100;
                        p = P2.make xy;
                        v = V2.zero;
                        a = A2.zero;
                }
        }

        let upd (Player p) dt = Player {
                p with
                be = {
                        p.be with
                        p = P2.upd p.be.p p.be.v dt;
                        v = V2.upd p.be.v p.be.a dt;
                }
        }
end

module Goblin = struct
        type t = Goblin of Being.t

        let make xy = Goblin {
                hp = Hp.make 0 50;
                mp = Mp.make 0 10;
                p = P2.make xy;
                v = V2.zero;
                a = A2.zero;
        }

        let upd (Goblin e) dt = Goblin (Being.upd e dt)
end

let rec loop player goblin dt =
        let player = Player.upd player dt in
        let goblin = Goblin.upd goblin dt in
        loop player goblin dt

let main () =
        let player = Player.make "Joe" {x=0.0; y=0.0} in
        let goblin = Goblin.make {x=1.0; y=1.0} in
        let dt = Seconds 0.50 in
        loop player goblin dt
