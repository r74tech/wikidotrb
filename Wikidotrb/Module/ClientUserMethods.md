---
layout: default
title: ClientUserMethods
parent: Module
nav_order: 1clientusermethods
has_children: true
---

# ClientUserMethods

**Class in namespace:** `Wikidotrb::Module`

**Inherits:** `Object`

## Instance Methods

### `client`

<div class="method-signature">client</div>

Returns the value of attribute client.

---

### `get`

<div class="method-signature">get(name, raise_when_not_found: false)</div>

Get a user object from a username

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">name</span> — Username
* <span class="parameter-name">raise_when_not_found:</span> = false
</div>

**Returns:**

User object

---

### `get_bulk`

<div class="method-signature">get_bulk(names, raise_when_not_found: false)</div>

Get user objects from a list of usernames

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">names</span> — List of usernames
* <span class="parameter-name">raise_when_not_found:</span> = false
</div>

**Returns:**

List of user objects

---

### `initialize`

<div class="method-signature">initialize(client)</div>

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">client</span>
</div>

**Returns:**

a new instance of ClientUserMethods

---

