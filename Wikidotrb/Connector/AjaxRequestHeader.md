---
layout: default
title: AjaxRequestHeader
parent: Connector
nav_order: 1ajaxrequestheader
has_children: true
---

# AjaxRequestHeader

**Class in namespace:** `Wikidotrb::Connector`

**Inherits:** `Object`

## Instance Methods

### `delete_cookie`

<div class="method-signature">delete_cookie(name)</div>

Cookieを削除

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">name</span> — Cookie名
</div>

---

### `get_cookie`

<div class="method-signature">get_cookie(name)</div>

Cookieを取得

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">name</span> — Cookie名
</div>

**Returns:**

Cookie値

---

### `get_header`

<div class="method-signature">get_header</div>

ヘッダを構築して返す

**Returns:**

ヘッダのハッシュ

---

### `initialize`

<div class="method-signature">initialize(content_type: nil, user_agent: nil, referer: nil, cookie: nil)</div>

AjaxRequestHeaderオブジェクトの初期化

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">content_type:</span> = nil
* <span class="parameter-name">user_agent:</span> = nil
* <span class="parameter-name">referer:</span> = nil
* <span class="parameter-name">cookie:</span> = nil
</div>

**Returns:**

a new instance of AjaxRequestHeader

---

### `set_cookie`

<div class="method-signature">set_cookie(name, value)</div>

Cookieを設定

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">name</span> — Cookie名
* <span class="parameter-name">value</span> — Cookie値
</div>

---

