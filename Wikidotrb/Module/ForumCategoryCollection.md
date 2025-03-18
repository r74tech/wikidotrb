---
layout: default
title: ForumCategoryCollection
parent: Module
nav_order: 1forumcategorycollection
has_children: true
---

# ForumCategoryCollection

**Class in namespace:** `Wikidotrb::Module`

**Inherits:** `Array`

## Class Methods

### `acquire_update`

<div class="method-signature">acquire_update(forum:, categories:)</div>

カテゴリ情報を取得して更新する

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">forum:</span>
* <span class="parameter-name">categories:</span>
</div>

**Returns:**

更新されたカテゴリのリスト

---

### `get_categories`

<div class="method-signature">get_categories(site:, forum:)</div>

サイトとフォーラムからカテゴリを取得

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">site:</span>
* <span class="parameter-name">forum:</span>
</div>

---

## Instance Methods

### `find`

<div class="method-signature">find(id: nil, title: nil)</div>

IDまたはタイトルからカテゴリを検索

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">id:</span> = nil
* <span class="parameter-name">title:</span> = nil
</div>

**Returns:**

一致するカテゴリ

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

<div class="method-signature">initialize(forum:, categories: [])</div>

初期化メソッド

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">forum:</span>
* <span class="parameter-name">categories:</span> = []
</div>

**Returns:**

a new instance of ForumCategoryCollection

---

### `update`

<div class="method-signature">update</div>

カテゴリ情報を更新

---

