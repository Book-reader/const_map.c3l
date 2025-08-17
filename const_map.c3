module const_map {Key, Value};
import const_map::internal @public;

struct Temp @private {Key key; Value val;}

<*
 @require $defined((Key){}.@const_hash) &&& $defined((Key){}.rt_hash) : "The key must support both compile-time and runtime hashing, and both must use the same algorithm (looking at you String)"
*>
macro @new_hashed(...) @const
{
	Entry {Key, Value, $vacount, true}[$vacount] $temp;
	$for var $i = 0; $i < $vacount; $i++:
		Temp $t = $vaexpr[$i];
		$temp[$i] = {$t.key.@const_hash(), $t.key, $t.val};
	$endfor

	ConstMap {Key, Value, $vacount, true} $new = {$temp};
	return $new;
}

<*
 @require $defined(((Key){}) == ((Key){})) : "They key must support the equality operator, but compile-time methods may not work unless it's a builtin type"
*>
macro @new_equal(...) @const
{
	Entry {Key, Value, $vacount, false}[$vacount] $temp;
	$for var $i = 0; $i < $vacount; $i++:
		Temp $t = $vaexpr[$i];
		$temp[$i] = {$t.key, $t.val};
	$endfor

	ConstMap {Key, Value, $vacount, false} $new = {$temp};
	return $new;
}

module const_map::internal {Key, Value, SIZE, USE_HASHING} @private;

struct Entry
{
	uint hash @if(USE_HASHING);
	Key key;
	Value val;
}

struct ConstMap
{
	Entry[SIZE] data;
}

macro usz ConstMap.len(#self) @const @safemacro @operator(len) => SIZE;

macro ConstMap.@each($self; @body($entry))
{
	$for var $i = 0; $i < $self.len(); $i ++:
		@body($self.data[$i]);
	$endfor
}

macro ConstMap.@each_key($self; @body($key)) => $self.@each(; $entry)
{
	$body($entry.key);
}

macro ConstMap.@each_value(&self; @body($value)) => $self.@each(; $entry)
{
	$body($entry.value);
}

// Methods using hashing
fn bool ConstMap.has_key(&self, Key key) @if(USE_HASHING)
{
	uint hash = key.rt_hash();
	foreach (&entry : self.data)
	{
		if (entry.hash == hash) return true;
	}
	return false;
}

fn Value? ConstMap.get(&self, Key key) @operator([]) @if(USE_HASHING)
{
	uint hash = key.rt_hash();
	foreach (&entry : self.data)
	{
		if (entry.hash == hash) return entry.val;
	}
	return NOT_FOUND?;
}

macro bool ConstMap.@has_key($self, Key $key) @const @if(USE_HASHING)
{
	$for var $i = 0; $i < $self.len(); $i ++:
		$if $self.data[$i].hash == $key.@const_hash():
			return true;
		$endif
	$endfor
	return false;
}

macro Value ConstMap.@get($self, Key $key) @const @if(USE_HASHING)
{
	bool $found;
	$for var $i = 0; $i < $self.len(); $i ++:
		$if $self.data[$i].hash == $key.@const_hash():
			$found = true;
			return $self.data[$i].val;
		$endif
	$endfor
	$if !$found:
		$error @sprintf("Key '%s' does not exist in the map", $key);
	$endif
}

// Methods using equality
fn bool ConstMap.has_key(&self, Key key) @if(!USE_HASHING)
{
	foreach (&entry : self.data)
	{
		if (entry.key == key) return true;
	}
	return false;
}

fn Value? ConstMap.get(&self, Key key) @operator([]) @if(!USE_HASHING)
{
	foreach (&entry : self.data)
	{
		if (entry.key == key) return entry.val;
	}
	return NOT_FOUND?;
}

macro bool ConstMap.@has_key($self, Key $key) @const @if(!USE_HASHING)
{
	$for var $i = 0; $i < $self.len(); $i ++:
		$if $self.data[$i].key == $key:
			return true;
		$endif
	$endfor
	return false;
}

macro Value ConstMap.@get($self, Key $key) @const @if(!USE_HASHING)
{
	bool $found;
	$for var $i = 0; $i < $self.len(); $i ++:
		$if $self.data[$i].key == $key:
			$found = true;
			return $self.data[$i].val;
		$endif
	$endfor
	$if !$found:
		$error @sprintf("Key '%s' does not exist in the map", $key);
	$endif
}

