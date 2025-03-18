---
layout: default
title: UserParser
parent: Parser
nav_order: 1userparser
has_children: true
---

# UserParser

**Class in namespace:** `Wikidotrb::Util::Parser`

**Inherits:** `Object`

UserParser parses HTML elements containing user information on Wikidot pages
and converts them into corresponding user objects

## Class Methods

### `deleted_user_string?`

<div class="method-signature">deleted_user_string?(elem)</div>

Check if the input is specifically the string "(user deleted)"

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">elem</span> — The element or string to check
</div>

**Returns:**

true if the input is the string "(user deleted)", false otherwise

---

### `gravatar_avatar?`

<div class="method-signature">gravatar_avatar?(elem)</div>

Check if the element contains a Gravatar avatar (used to identify guest users)

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">elem</span> — Element to check for Gravatar
</div>

**Returns:**

true if the element contains a Gravatar image, false otherwise

---

### `parse`

<div class="method-signature">parse(client, elem)</div>

Parse printuser element and return a user object

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">client</span> — The client instance used for API communication
* <span class="parameter-name">elem</span> — The element to parse (element with printuser class),
can also be a string containing HTML or the literal string "(user deleted)"
</div>

**Returns:**

The parsed user object or nil if parsing fails

**Examples:**

```ruby
html = '<span class="printuser"><a href="http://www.wikidot.com/user:info/username">Username</a></span>'
element = Nokogiri::HTML.fragment(html).at_css('.printuser')
user = UserParser.parse(client, element)
```

---

### `parse_anonymous_user`

<div class="method-signature">parse_anonymous_user(client, elem)</div>

Parse an anonymous user element (IP address user)

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">client</span> — The client instance used for API communication
* <span class="parameter-name">elem</span> — Element with "anonymous" class
</div>

**Returns:**

Anonymous user object with IP information

---

### `parse_deleted_user`

<div class="method-signature">parse_deleted_user(client, elem)</div>

Parse a deleted user element

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">client</span> — The client instance used for API communication
* <span class="parameter-name">elem</span> — Element with "deleted" class
</div>

**Returns:**

The deleted user object with ID if available

---

### `parse_guest_user`

<div class="method-signature">parse_guest_user(client, elem)</div>

Parse a guest user element (typically with Gravatar)

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">client</span> — The client instance used for API communication
* <span class="parameter-name">elem</span> — Element containing guest user info with Gravatar
</div>

**Returns:**

Guest user object with name and avatar URL

---

### `parse_regular_user`

<div class="method-signature">parse_regular_user(client, elem)</div>

Parse a regular registered Wikidot user

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">client</span> — The client instance used for API communication
* <span class="parameter-name">elem</span> — Element containing registered user information
</div>

**Returns:**

Regular user object with ID, name and other details,
or nil if user anchor cannot be found

---

### `parse_wikidot_user`

<div class="method-signature">parse_wikidot_user(client)</div>

Parse a special Wikidot system user

**Parameters:**

<div class="method-parameters">
* <span class="parameter-name">client</span> — The client instance used for API communication
</div>

**Returns:**

Wikidot system user object

---

