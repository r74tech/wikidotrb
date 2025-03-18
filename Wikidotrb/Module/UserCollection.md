---
layout: default
title: UserCollection
parent: Module
nav_order: 1usercollection
has_children: true
---

# UserCollection

**Class in namespace:** `Wikidotrb::Module`

**Inherits:** `Array`

Class representing a collection of users

## Class Methods

### `from_names`

<div class="method-signature">from_names(client, names, raise_when_not_found = false)</div>

Get a list of user objects from a list of usernames

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">client</span> — The client
* <span class="parameter-name">names</span> — List of usernames
* <span class="parameter-name">raise_when_not_found</span> = false — Whether to raise an exception when a user is not found
</div>

**Returns:**

List of user objects

---

