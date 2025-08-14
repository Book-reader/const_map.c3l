module main;
import const_map;
import std::io;
import std::hash::fnv32a;

macro uint String.@const_hash($self) @const => @str_hash($self);
macro uint String.rt_hash(self) => (uint)fnv32a::hash(self);

macro uint int.@const_hash($self) => $self;
macro uint int.rt_hash(self) => self;

const CONST_MAP = const_map::@new{String, String}(
	{"foo", "bar"},
	{"bar", "baz"},
);

const FOO = const_map::@new{int, String}(
	{0, "hello"},
	{1, "world!"},
);

fn void main()
{
	CONST_MAP.@each(; $entry)
	{
		$echo @sprintf("%s:%s:%s", $entry.hash, $entry.key, $entry.val);
	};
	String s = "foo";
	io::printfn("%s %s %s", CONST_MAP.has_key(s), CONST_MAP["foo"]!!, CONST_MAP.@has_key("baz"));
}
