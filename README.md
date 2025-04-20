
# log-timestamps.el

**log-timestamps.el** is a lightweight Emacs minor mode that highlights 13-digit millisecond epoch timestamps with inline UTC dates.

## Features

- Automatically detects timestamps like `1713539200000`
- Displays inline readable date: `→ 2024-04-19 15:00:00`
- Auto-enables in `org-mode`, `json-mode`, `prog-mode`, `logview-mode`
- Integrates cleanly with Doom Emacs using `SPC t`

## Installation

Clone the repo and load it from your Doom config:

```elisp
(add-to-list 'load-path "~/path/to/log-timestamps")
(require 'log-timestamps)

