---
layout: default
title: WikidotStatusCodeException
parent: Exceptions
nav_order: 1wikidotstatuscodeexception
has_children: true
---

# WikidotStatusCodeException

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

a new instance of WikidotStatusCodeException

---

### `status_code`

<div class="method-signature">status_code</div>

AMCから返却されたデータ内のステータスがokではなかったときの例外
HTTPステータスが200以外の場合はAMCHttpStatusCodeExceptionを投げる

---

