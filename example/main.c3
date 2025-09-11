module main;
import const_map;
import std::io;
import std::hash::fnv32a;

macro uint String.@const_hash($self) @const => @str_hash($self);
macro uint String.rt_hash(self) => self.hash();

const CONST_MAP = const_map::@new_hashed{String, String}(
	{"foo", "bar"},
	{"bar", "baz"},
);


struct Foo {int a; int b;}
fn bool Foo.eq(&self, Foo other) @operator(==) => self.a == other.a && self.b == other.b;
const CONST_MAP_2 = const_map::@new_equal{Foo, String}(
	{{1, 2}, "bar"},
	{{3, 4}, "baz"},
);

fn void main()
{
	CONST_MAP.@each(; $entry)
	{
		$echo @sprintf("%s:%s:%s", $entry.hash, $entry.key, $entry.val);
	};
	String s = "foo";
	io::printfn("%s %s %s", CONST_MAP.has_key(s), CONST_MAP["foo"]!!, CONST_MAP.@has_key("baz"));

	// This won't work because the equality doesn't work at compile-time:
	// $echo CONST_MAP_2.@has_key({1, 2});
	// This will however:
	io::printfn("%s", CONST_MAP_2.has_key({1, 2}));
}
