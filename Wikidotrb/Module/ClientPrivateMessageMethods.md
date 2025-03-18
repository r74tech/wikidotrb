---
layout: default
title: ClientPrivateMessageMethods
parent: Module
nav_order: 1clientprivatemessagemethods
has_children: true
---

# ClientPrivateMessageMethods

**Class in namespace:** `Wikidotrb::Module`

**Inherits:** `Object`

## Instance Methods

### `client`

<div class="method-signature">client</div>

Returns the value of attribute client.

---

### `get_inbox`

<div class="method-signature">get_inbox</div>

Get inbox

**Returns:**

Inbox

---

### `get_message`

<div class="method-signature">get_message(message_id)</div>

Get a message

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">message_id</span> — Message ID
</div>

**Returns:**

Message

---

### `get_messages`

<div class="method-signature">get_messages(message_ids)</div>

Get messages

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">message_ids</span> — List of message IDs
</div>

**Returns:**

List of messages

---

### `get_sentbox`

<div class="method-signature">get_sentbox</div>

Get sent box

**Returns:**

Sent box

---

### `initialize`

<div class="method-signature">initialize(client)</div>

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">client</span>
</div>

**Returns:**

a new instance of ClientPrivateMessageMethods

---

### `send_message`

<div class="method-signature">send_message(recipient, subject, body)</div>

Send a message

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">recipient</span> — Recipient
* <span class="parameter-name">subject</span> — Subject
* <span class="parameter-name">body</span> — Message body
</div>

---

