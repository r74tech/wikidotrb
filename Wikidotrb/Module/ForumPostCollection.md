---
layout: default
title: ForumPostCollection
parent: Module
nav_order: 1forumpostcollection
has_children: true
---

# ForumPostCollection

**Class in namespace:** `Wikidotrb::Module`

**Inherits:** `Array`

## Class Methods

### `acquire_parent_post`

<div class="method-signature">acquire_parent_post(thread:, posts:)</div>

Retrieve and set parent post

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">thread:</span>
* <span class="parameter-name">posts:</span>
</div>

**Returns:**

Updated list of posts

---

### `acquire_post_info`

<div class="method-signature">acquire_post_info(thread:, posts:)</div>

Retrieve and set post information

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">thread:</span>
* <span class="parameter-name">posts:</span>
</div>

**Returns:**

Updated list of posts

---

## Instance Methods

### `find`

<div class="method-signature">find(target_id)</div>

Search for a post by ID

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">target_id</span> — Post ID
</div>

**Returns:**

ForumPost object if the post is found, nil otherwise

---

### `get_parent_post`

<div class="method-signature">get_parent_post</div>

Retrieve parent post for revisions

---

### `get_post_info`

<div class="method-signature">get_post_info</div>

Retrieve post information for revisions

---

### `initialize`

<div class="method-signature">initialize(thread:, posts: [])</div>

Initialization method

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">thread:</span>
* <span class="parameter-name">posts:</span> = []
</div>

**Returns:**

a new instance of ForumPostCollection

---

### `thread`

<div class="method-signature">thread</div>

Returns the value of attribute thread.

---

### `thread=`

<div class="method-signature">thread=(value)</div>

Sets the attribute thread

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">value</span> — the value to set the attribute thread to.
</div>

---

