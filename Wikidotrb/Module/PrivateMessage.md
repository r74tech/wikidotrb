---
layout: default
title: PrivateMessage
parent: Module
nav_order: 1privatemessage
has_children: true
---

# PrivateMessage

**Class in namespace:** `Wikidotrb::Module`

**Inherits:** `Object`

## Class Methods

### `from_id`

<div class="method-signature">from_id(client:, message_id:)</div>

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">client:</span>
* <span class="parameter-name">message_id:</span>
</div>

---

### `login_required`

<div class="method-signature">login_required(*methods)</div>

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">*methods</span>
</div>

---

### `send_message`

<div class="method-signature">send_message(client:, recipient:, subject:, body:)</div>

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">client:</span>
* <span class="parameter-name">recipient:</span>
* <span class="parameter-name">subject:</span>
* <span class="parameter-name">body:</span>
</div>

---

## Instance Methods

### `body`

<div class="method-signature">body</div>

Returns the value of attribute body.

---

### `client`

<div class="method-signature">client</div>

Returns the value of attribute client.

---

### `created_at`

<div class="method-signature">created_at</div>

Returns the value of attribute created_at.

---

### `id`

<div class="method-signature">id</div>

Returns the value of attribute id.

---

### `initialize`

<div class="method-signature">initialize(client:, id:, sender:, recipient:, subject:, body:, created_at:)</div>

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">client:</span>
* <span class="parameter-name">id:</span>
* <span class="parameter-name">sender:</span>
* <span class="parameter-name">recipient:</span>
* <span class="parameter-name">subject:</span>
* <span class="parameter-name">body:</span>
* <span class="parameter-name">created_at:</span>
</div>

**Returns:**

a new instance of PrivateMessage

---

### `recipient`

<div class="method-signature">recipient</div>

Returns the value of attribute recipient.

---

### `sender`

<div class="method-signature">sender</div>

Returns the value of attribute sender.

---

### `subject`

<div class="method-signature">subject</div>

Returns the value of attribute subject.

---

### `to_s`

<div class="method-signature">to_s</div>

---

