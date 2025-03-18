---
layout: default
title: AMCHttpStatusCodeException
parent: Exceptions
nav_order: 1amchttpstatuscodeexception
has_children: true
---

# AMCHttpStatusCodeException

**Class in namespace:** `Wikidotrb::Common::Exceptions`

**Inherits:** `Wikidotrb::Common::Exceptions::AjaxModuleConnectorException`

## Instance Methods

### `initialize`

<div class="method-signature">initialize(message, status_code)</div>

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">message</span>
* <span class="parameter-name">status_code</span>
</div>

**Returns:**

a new instance of AMCHttpStatusCodeException

---

### `status_code`

<div class="method-signature">status_code</div>

AMCから返却されたHTTPステータスが200以外だったときの例外

---

