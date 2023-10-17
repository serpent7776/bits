#include <algorithm>
#include <limits>
#include <string>

struct Seconds {
	float s;
};
float operator*(Seconds s, float val) {
	return s.s * val;
}
float operator*(float val, Seconds s) {
	return s.s * val;
}

struct XY {
	float x;
	float y;

	friend XY operator*(XY xy, Seconds dt) {
		return XY {.x=xy.x * dt, .y=xy.y * dt};
	}
	friend void operator+=(XY& a, XY b) {
		a.x = a.x + b.x;
		a.y = a.y + b.y;
	}
};

struct A2 : XY {
};

struct V2 : XY {
	friend void upd(V2& v, A2 a, Seconds dt) {
		v += a * dt;
	}
};
struct P2 : XY {
	friend void upd(P2& p, V2 v, Seconds dt) {
		p += v * dt;
	}
};

struct Resource {
	int cur;
	int min;
	int max;

	friend void operator-=(Resource& r, int val) {
		r.cur -= std::min(r.cur, val);
	}
	friend Resource operator-(Resource r, int val) {
		r -= val;
		return r;
	}
	friend void operator+=(Resource& r, int val) {
		r.cur += std::min(std::numeric_limits<int>::max() - r.cur, val);
	}
	friend Resource operator+(Resource r, int val) {
		r += val;
		return r;
	}
};

struct Hp {
	Resource r;

	Hp(int min, int max) : r{.cur=max, .min=min, .max=max}
	{}
	Hp(Resource r) : r{.cur=r.cur, .min=r.min, .max=r.max}
	{}

	friend void operator-=(Hp& hp, int val) {
		hp.r -= val;
	}
	friend Hp operator-(Hp hp, int val) {
		return Hp{hp.r - val};
	}
	friend void operator+=(Hp& hp, int val) {
		hp.r += val;
	}
	friend Hp operator+(Hp hp, int val) {
		return Hp{hp.r + val};
	}
};

struct Mp {
	Resource r;

	Mp(int min, int max) : r{.cur=max, .min=min, .max=max}
	{}
	Mp(Resource r) : r{.cur=r.cur, .min=r.min, .max=r.max}
	{}

	friend void operator-=(Mp& mp, int val) {
		mp.r -= val;
	}
	friend Mp operator-(Mp mp, int val) {
		return Mp{mp.r - val};
	}
	friend void operator+=(Mp& mp, int val) {
		mp.r += val;
	}
	friend Mp operator+(Mp mp, int val) {
		return Mp{mp.r + val};
	}
};

struct Lives {
	Resource r;

	Lives(int min, int max) : r{.cur=max, .min=min, .max=max}
	{}
	Lives(Resource r) : r{.cur=r.cur, .min=r.min, .max=r.max}
	{}

	friend void operator-=(Lives& l, int val) {
		l.r -= val;
	}
	friend Lives operator-(Lives l, int val) {
		return Lives{l.r - val};
	}
	friend void operator+=(Lives l, int val) {
		l.r += val;
	}
	friend Lives operator+(Lives& l, int val) {
		return Lives{l.r + val};
	}
};

struct Being {
	Hp hp;
	Mp mp;
	P2 p;
	V2 v;
	A2 a;
};

struct Player : Being {
	std::string name;
	Lives lives;

	Player(std::string name, float x, float y) :
		Being{.hp{-100, 100}, .mp{0, 100}, .p{x, y}, .v{0, 0}, .a{0, 0}},
		name(std::move(name)),
		lives(0, 3)
	{}

	friend void upd(Player& p, Seconds dt) {
		upd(p.p, p.v, dt);
		upd(p.v, p.a, dt);
	}
};

struct Goblin : Being {
	Goblin(float x, float y) : Being{.hp{-100, 100}, .mp{0, 0}, .p{x, y}, .v{0, 0}, .a{0, 0}}
	{}

	friend void upd(Goblin& e, Seconds dt) {
		upd(e.p, e.v, dt);
		upd(e.v, e.a, dt);
	}
};

void game_loop(Player p, Goblin e, Seconds dt) {
	while (true) {
		upd(p, dt);
		upd(e, dt);
	}
}

int main()
{
	Player p("Joe", 0, 0);
	Goblin e(1, 1);
	Seconds dt{50};
	game_loop(p, e, dt);
	return 0;
}
