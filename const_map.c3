<*
 @require $defined((Key){}.@const_hash) &&& $defined((Key){}.rt_hash) : "The key must support both compile-time and runtime hashing, and both must use the same algorithm (looking at you String)"
*>
module const_map {Key, Value};
import const_map::internal @public;

struct Temp @private {Key key; Value val;}

macro @new(...) @const
{
	Entry {Key, Value, $vacount}[$vacount] $temp;
	$for var $i = 0; $i < $vacount; $i++:
		Temp $t = $vaexpr[$i];
		$temp[$i] = {$t.key.@const_hash(), $t.key, $t.val};
	$endfor

	ConstMap {Key, Value, $vacount} $new = {$temp};
	return $new;
}

module const_map::internal {Key, Value, SIZE} @private;

struct Entry
{
	uint hash;
	Key key;
	Value val;
}

struct ConstMap
{
	Entry[SIZE] data;
}

fn bool ConstMap.has_key(&self, Key key)
{
	uint hash = key.rt_hash();
	foreach (&entry : self.data)
	{
		if (entry.hash == hash) return true;
	}
	return false;
}

fn Value? ConstMap.get(&self, Key key) @operator([])
{
	uint hash = key.rt_hash();
	foreach (&entry : self.data)
	{
		if (entry.hash == hash) return entry.val;
	}
	return NOT_FOUND?;
}

macro usz ConstMap.len(#self) @const @safemacro @operator(len) => SIZE;

macro ConstMap.@each(&self; @body(entry))
{
	foreach (entry : self.data) @body(entry);
}

macro ConstMap.@each_key(&self; @body(key))
{
	foreach (&entry : self.data) @body(entry.key);
}

macro ConstMap.@each_value(&self; @body(value))
{
	foreach (&entry : self.data) @body(entry.value);
}
