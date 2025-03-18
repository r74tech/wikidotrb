---
layout: default
title: ForumGroupCollection
parent: Module
nav_order: 1forumgroupcollection
has_children: true
---

# ForumGroupCollection

**Class in namespace:** `Wikidotrb::Module`

**Inherits:** `Array`

## Class Methods

### `get_groups`

<div class="method-signature">get_groups(site:, forum:)</div>

Get groups from site and forum

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">site:</span>
* <span class="parameter-name">forum:</span>
</div>

---

## Instance Methods

### `find`

<div class="method-signature">find(title: nil, description: nil)</div>

Search for a group by title and description

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">title:</span> = nil
* <span class="parameter-name">description:</span> = nil
</div>

**Returns:**

Found group or nil

---

### `findall`

<div class="method-signature">findall(title: nil, description: nil)</div>

Search for all groups matching the conditions

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">title:</span> = nil
* <span class="parameter-name">description:</span> = nil
</div>

**Returns:**

List of found groups

---

### `forum`

<div class="method-signature">forum</div>

Returns the value of attribute forum.

---

### `forum=`

<div class="method-signature">forum=(value)</div>

Sets the attribute forum

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">value</span> — the value to set the attribute forum to.
</div>

---

### `initialize`

<div class="method-signature">initialize(forum:, groups: [])</div>

Initialization method

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">forum:</span>
* <span class="parameter-name">groups:</span> = []
</div>

**Returns:**

a new instance of ForumGroupCollection

---

