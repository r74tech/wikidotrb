---
layout: default
title: SitePageMethods
parent: Module
nav_order: 1sitepagemethods
has_children: true
---

# SitePageMethods

**Class in namespace:** `Wikidotrb::Module`

**Inherits:** `Object`

## Instance Methods

### `create`

<div class="method-signature">create(fullname:, title: "", source: "", comment: "", force_edit: false)</div>

Create a page

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">fullname:</span>
* <span class="parameter-name">title:</span> = ""
* <span class="parameter-name">source:</span> = ""
* <span class="parameter-name">comment:</span> = ""
* <span class="parameter-name">force_edit:</span> = false
</div>

**Returns:**

Created page object

---

### `get`

<div class="method-signature">get(fullname, raise_when_not_found: true)</div>

Get a page by its fullname

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">fullname</span> — Page fullname
* <span class="parameter-name">raise_when_not_found:</span> = true
</div>

**Returns:**

Page object or nil

---

### `initialize`

<div class="method-signature">initialize(site)</div>

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">site</span>
</div>

**Returns:**

a new instance of SitePageMethods

---

