---
layout: default
title: ForumThread
parent: Module
nav_order: 1forumthread
has_children: true
---

# ForumThread

**Class in namespace:** `Wikidotrb::Module`

**Inherits:** `Object`

## Instance Methods

### `category`

<div class="method-signature">category</div>

Returns the value of attribute category.

---

### `category=`

<div class="method-signature">category=(value)</div>

Sets the attribute category

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">value</span> — the value to set the attribute category to.
</div>

---

### `created_at`

<div class="method-signature">created_at</div>

Returns the value of attribute created_at.

---

### `created_at=`

<div class="method-signature">created_at=(value)</div>

Sets the attribute created_at

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">value</span> — the value to set the attribute created_at to.
</div>

---

### `created_by`

<div class="method-signature">created_by</div>

Returns the value of attribute created_by.

---

### `created_by=`

<div class="method-signature">created_by=(value)</div>

Sets the attribute created_by

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">value</span> — the value to set the attribute created_by to.
</div>

---

### `description`

<div class="method-signature">description</div>

Returns the value of attribute description.

---

### `description=`

<div class="method-signature">description=(value)</div>

Sets the attribute description

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">value</span> — the value to set the attribute description to.
</div>

---

### `edit`

<div class="method-signature">edit(title: nil, description: nil)</div>

スレッドの編集

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">title:</span> = nil
* <span class="parameter-name">description:</span> = nil
</div>

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

### `get`

<div class="method-signature">get(post_id)</div>

投稿を取得する

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">post_id</span>
</div>

---

### `get_url`

<div class="method-signature">get_url</div>

スレッドのURLを取得する

---

### `id`

<div class="method-signature">id</div>

Returns the value of attribute id.

---

### `id=`

<div class="method-signature">id=(value)</div>

Sets the attribute id

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">value</span> — the value to set the attribute id to.
</div>

---

### `initialize`

<div class="method-signature">initialize(site:, id:, forum:, category: nil, title: nil, description: nil, created_by: nil, created_at: nil, posts_counts: nil, page: nil, pagerno: nil, last_post_id: nil)</div>

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">site:</span>
* <span class="parameter-name">id:</span>
* <span class="parameter-name">forum:</span>
* <span class="parameter-name">category:</span> = nil
* <span class="parameter-name">title:</span> = nil
* <span class="parameter-name">description:</span> = nil
* <span class="parameter-name">created_by:</span> = nil
* <span class="parameter-name">created_at:</span> = nil
* <span class="parameter-name">posts_counts:</span> = nil
* <span class="parameter-name">page:</span> = nil
* <span class="parameter-name">pagerno:</span> = nil
* <span class="parameter-name">last_post_id:</span> = nil
</div>

**Returns:**

a new instance of ForumThread

---

### `last`

<div class="method-signature">last</div>

最後の投稿の取得

---

### `last=`

<div class="method-signature">last=(value)</div>

最後の投稿を設定

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">value</span>
</div>

---

### `lock`

<div class="method-signature">lock</div>

スレッドのロック

---

### `locked?`

<div class="method-signature">locked?</div>

スレッドがロックされているか確認

**Returns:**



---

### `move_to`

<div class="method-signature">move_to(category_id)</div>

スレッドのカテゴリ移動

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">category_id</span>
</div>

---

### `new_post`

<div class="method-signature">new_post(title: "", source: "", parent_id: "")</div>

新しい投稿を作成する

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">title:</span> = ""
* <span class="parameter-name">source:</span> = ""
* <span class="parameter-name">parent_id:</span> = ""
</div>

---

### `page`

<div class="method-signature">page</div>

Returns the value of attribute page.

---

### `page=`

<div class="method-signature">page=(value)</div>

Sets the attribute page

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">value</span> — the value to set the attribute page to.
</div>

---

### `pagerno`

<div class="method-signature">pagerno</div>

Returns the value of attribute pagerno.

---

### `pagerno=`

<div class="method-signature">pagerno=(value)</div>

Sets the attribute pagerno

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">value</span> — the value to set the attribute pagerno to.
</div>

---

### `posts`

<div class="method-signature">posts</div>

投稿のコレクションを取得する

**Returns:**

投稿オブジェクトのコレクション

---

### `posts_counts`

<div class="method-signature">posts_counts</div>

Returns the value of attribute posts_counts.

---

### `posts_counts=`

<div class="method-signature">posts_counts=(value)</div>

Sets the attribute posts_counts

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">value</span> — the value to set the attribute posts_counts to.
</div>

---

### `site`

<div class="method-signature">site</div>

Returns the value of attribute site.

---

### `site=`

<div class="method-signature">site=(value)</div>

Sets the attribute site

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">value</span> — the value to set the attribute site to.
</div>

---

### `stick`

<div class="method-signature">stick</div>

スレッドを固定する

---

### `sticked?`

<div class="method-signature">sticked?</div>

スレッドが固定されているか確認

**Returns:**



---

### `title`

<div class="method-signature">title</div>

Returns the value of attribute title.

---

### `title=`

<div class="method-signature">title=(value)</div>

Sets the attribute title

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">value</span> — the value to set the attribute title to.
</div>

---

### `unlock`

<div class="method-signature">unlock</div>

スレッドのアンロック

---

### `unstick`

<div class="method-signature">unstick</div>

スレッドの固定を解除する

---

### `update`

<div class="method-signature">update</div>

スレッドを更新する

---

