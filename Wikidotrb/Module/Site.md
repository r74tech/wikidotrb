---
layout: default
title: Site
parent: Module
nav_order: 1site
has_children: true
---

# Site

**Class in namespace:** `Wikidotrb::Module`

**Inherits:** `Object`

## Class Methods

### `from_unix_name`

<div class="method-signature">from_unix_name(client:, unix_name:)</div>

Get a site object by its UNIX name

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">client:</span>
* <span class="parameter-name">unix_name:</span>
</div>

**Returns:**

Site object

---

### `login_required`

<div class="method-signature">login_required(*methods)</div>

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">*methods</span>
</div>

---

## Instance Methods

### `amc_request`

<div class="method-signature">amc_request(bodies:, return_exceptions: false)</div>

Execute an AMC request for this site

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">bodies:</span>
* <span class="parameter-name">return_exceptions:</span> = false
</div>

---

### `client`

<div class="method-signature">client</div>

Returns the value of attribute client.

---

### `domain`

<div class="method-signature">domain</div>

Returns the value of attribute domain.

---

### `get_applications`

<div class="method-signature">get_applications</div>

Get pending membership applications for the site

**Returns:**

List of pending applications

---

### `get_url`

<div class="method-signature">get_url</div>

Get the site URL

**Returns:**

Site URL

---

### `id`

<div class="method-signature">id</div>

Returns the value of attribute id.

---

### `initialize`

<div class="method-signature">initialize(client:, id:, title:, unix_name:, domain:, ssl_supported:)</div>

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">client:</span>
* <span class="parameter-name">id:</span>
* <span class="parameter-name">title:</span>
* <span class="parameter-name">unix_name:</span>
* <span class="parameter-name">domain:</span>
* <span class="parameter-name">ssl_supported:</span>
</div>

**Returns:**

a new instance of Site

---

### `invite_user`

<div class="method-signature">invite_user(user:, text:)</div>

Invite a user to the site

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">user:</span>
* <span class="parameter-name">text:</span>
</div>

---

### `page`

<div class="method-signature">page</div>

Returns the value of attribute page.

---

### `pages`

<div class="method-signature">pages</div>

Returns the value of attribute pages.

---

### `ssl_supported`

<div class="method-signature">ssl_supported</div>

Returns the value of attribute ssl_supported.

---

### `title`

<div class="method-signature">title</div>

Returns the value of attribute title.

---

### `to_s`

<div class="method-signature">to_s</div>

---

### `unix_name`

<div class="method-signature">unix_name</div>

Returns the value of attribute unix_name.

---

