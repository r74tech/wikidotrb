---
layout: default
title: AjaxModuleConnectorClient
parent: Connector
nav_order: 1ajaxmoduleconnectorclient
has_children: true
---

# AjaxModuleConnectorClient

**Class in namespace:** `Wikidotrb::Connector`

**Inherits:** `Object`

## Instance Methods

### `check_existence_and_ssl`

<div class="method-signature">check_existence_and_ssl(site_name)</div>

サイトの存在とSSLの対応をチェック

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">site_name</span>
</div>

**Returns:**

SSL対応しているか

---

### `config`

<div class="method-signature">config</div>

Returns the value of attribute config.

---

### `header`

<div class="method-signature">header</div>

Returns the value of attribute header.

---

### `initialize`

<div class="method-signature">initialize(site_name:, config: nil)</div>

AjaxModuleConnectorClientオブジェクトの初期化

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">site_name:</span>
* <span class="parameter-name">config:</span> = nil
</div>

**Returns:**

a new instance of AjaxModuleConnectorClient

---

### `request`

<div class="method-signature">request(bodies:, return_exceptions: false, site_name: nil, site_ssl_supported: nil)</div>

ajax-module-connector.phpへのリクエストを行う

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">bodies:</span>
* <span class="parameter-name">return_exceptions:</span> = false
* <span class="parameter-name">site_name:</span> = nil
* <span class="parameter-name">site_ssl_supported:</span> = nil
</div>

**Returns:**

レスポンスボディのリスト

---

### `site_name`

<div class="method-signature">site_name</div>

Returns the value of attribute site_name.

---

