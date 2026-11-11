---@meta _

---@class bufferlines.DebugOpts
---@field logging boolean

---@class bufferlines.GroupOptions
---@field toggle_hidden_on_enter? boolean re-open hidden groups on bufenter

---@class bufferlines.GroupOpts
---@field options? bufferlines.GroupOptions
---@field items bufferlines.Group[]

---@class bufferlines.Indicator
---@field style? "underline" | "icon" | "none"
---@field icon? string?

---@alias bufferlines.Mode 'tabs' | 'buffers'

---@alias bufferlines.DiagnosticIndicator fun(count: number, level: string, errors: table<string, any>, ctx: table<string, any>): string

---@alias bufferlines.HoverOptions {reveal: string[], delay: integer, enabled: boolean}
---@alias bufferlines.IconFetcherOpts {directory: boolean, path: string, extension: string, filetype: string?}

---@class bufferlines.MultilineOptions
---@field enabled? boolean
---@field max_rows? integer

---@class bufferlines.Options
---@field public multiline? bufferlines.MultilineOptions
---@field public mode? bufferlines.Mode
---@field public style_preset? bufferlines.StylePreset | bufferlines.StylePreset[]
---@field public view? string
---@field public debug? bufferlines.DebugOpts
---@field public numbers? 'none' | 'ordinal' | 'buffer_id' | 'both' | fun(opts: { ordinal: number, id: number, lower: number_helper, raise: number_helper }): string
---@field public buffer_close_icon? string
---@field public modified_icon? string
---@field public close_icon? string
---@field public close_command? string | function
---@field public custom_filter? fun(buf: number, bufnums: number[]): boolean
---@field public left_mouse_command? string | function
---@field public right_mouse_command? string | function
---@field public middle_mouse_command? (string | function)?
---@field public indicator? bufferlines.Indicator
---@field public left_trunc_marker? string
---@field public right_trunc_marker? string
---@field public separator_style? string | {[1]: string, [2]: string}
---@field public name_formatter? (fun(path: string):string)?
---@field public tab_size? number
---@field public truncate_names? boolean
---@field public max_name_length? number
---@field public color_icons? boolean
---@field public show_buffer_icons? boolean
---@field public show_buffer_close_icons? boolean
---@field public get_element_icon? fun(opts: bufferlines.IconFetcherOpts): string?, string?
---@field public show_close_icon? boolean
---@field public show_tab_indicators? boolean
---@field public show_duplicate_prefix? boolean
---@field public duplicates_across_groups? boolean
---@field public enforce_regular_tabs? boolean
---@field public always_show_bufferline? boolean
---@field public auto_toggle_bufferline? boolean
---@field public persist_buffer_sort? boolean
---@field public move_wraps_at_ends? boolean
---@field public max_prefix_length? number
---@field public sort_by? 'insert_after_current' | 'insert_at_end' | 'id' | 'extension' | 'relative_directory' | 'directory' | 'tabs' | fun(buffer_a: bufferlines.Buffer, buffer_b: bufferlines.Buffer): boolean
---@field public diagnostics? boolean | 'nvim_lsp' | 'coc'
---@field public diagnostics_indicator? bufferlines.DiagnosticIndicator
---@field public diagnostics_update_in_insert? boolean
---@field public diagnostics_update_on_event? boolean
---@field public offsets? table[]
---@field public groups? bufferlines.GroupOpts
---@field public themable? boolean
---@field public hover? bufferlines.HoverOptions

---@class bufferlines.HLLink
---@field attribute 'fg' | 'bg'
---@field highlight string

---@class bufferlines.HLGroup
---@field fg? string | bufferlines.HLLink
---@field bg? string | bufferlines.HLLink
---@field sp? string
---@field special? string
---@field bold? boolean
---@field italic? boolean
---@field underline? boolean
---@field undercurl? boolean
---@field hl_group? string
---@field hl_name? string

---@alias bufferlines.Highlights table<string, bufferlines.HLGroup>

---@class bufferlines.UserConfig
---@field public options? bufferlines.Options
---@field public highlights? bufferlines.Highlights | fun(BufferlinesHighlights): bufferlines.Highlights

---@class bufferlines.Config
---@field public options? bufferlines.Options
---@field public highlights? bufferlines.Highlights
---@field user bufferlines.UserConfig original copy of user preferences
---@field merge fun(self: bufferlines.Config, defaults: bufferlines.Config): bufferlines.Config
---@field validate fun(self: bufferlines.Config, defaults: bufferlines.Config, resolved: bufferlines.Highlights): nil
---@field resolve fun(self: bufferlines.Config, defaults: bufferlines.Config): bufferlines.Config
---@field is_tabline fun(self: bufferlines.Config):boolean

--- @alias bufferlines.Visibility 1 | 2 | 3
--- @alias bufferlines.Duplicate "path" | "element" | nil

---@class bufferlines.Component
---@field name? string
---@field id integer
---@field path? string
---@field length integer
---@field component fun(BufferlinesState): bufferlines.Segment[]
---@field hidden boolean
---@field focusable boolean
---@field type 'group_end' | 'group_start' | 'buffer' | 'tabpage'

---@generic T
---@alias bufferlines.AncestorSearch fun(self: T, depth: integer, formatter: (fun(string, integer): string)?): string

---@alias bufferlines.TabElement bufferlines.Tab|bufferlines.Buffer

---@class bufferlines.Tab
---@field public id integer
---@field public buf integer
---@field public icon string
---@field public name string
---@field public group string
---@field public letter string
---@field public modified boolean
---@field public modifiable boolean
---@field public duplicated bufferlines.Duplicate
---@field public extension string the file extension
---@field public path string the full path to the file
---@field public visibility fun(self: bufferlines.Tab): integer
---@field public current fun(self: bufferlines.Tab): boolean
---@field public visible fun(self: bufferlines.Tab): boolean
---@field public ancestor bufferlines.AncestorSearch
---@field public __ancestor bufferlines.AncestorSearch

-- A single buffer class
-- this extends the [Component] class
---@class bufferlines.Buffer
---@field public extension string the file extension
---@field public path string the full path to the file
---@field public name_formatter function? dictates how the name should be shown
---@field public id integer the buffer number
---@field public name string the visible name for the file
---@field public filename string
---@field public icon string the icon
---@field public icon_highlight string?
---@field public diagnostics table
---@field public modified boolean
---@field public modifiable boolean
---@field public buftype string
---@field public letter string?
---@field public ordinal integer
---@field public duplicated bufferlines.Duplicate
---@field public prefix_count integer
---@field public component BufferComponent
---@field public group string?
---@field public group_fn string
---@field public length integer the length of the buffer component
---@field public visibility fun(self: bufferlines.Buffer): integer
---@field public current fun(self: bufferlines.Buffer): boolean
---@field public visible fun(self: bufferlines.Buffer): boolean
---@field public ancestor bufferlines.AncestorSearch
---@field public __ancestor bufferlines.AncestorSearch
---@field public find_index fun(Buffer, BufferlinesState): integer?
---@field public newly_opened fun(Buffer, BufferlinesState): boolean
---@field public previously_opened fun(Buffer, BufferlinesState): boolean

---@alias bufferlines.ComponentsByGroup (bufferlines.Group | bufferlines.Component[])[]

--- @class bufferlines.GroupState
--- @field manual_groupings table<number, string>
--- @field user_groups table<string, bufferlines.Group>
--- @field components_by_group bufferlines.ComponentsByGroup

--- @class bufferlines.Separators
--- @field sep_start bufferlines.Segment[]
--- @field sep_end bufferlines.Segment[]

---@alias GroupSeparator fun(group:bufferlines.Group, hls: bufferlines.HLGroup, count_item: string?): bufferlines.Separators
---@alias GroupSeparators table<string, GroupSeparator>

---@class bufferlines.Group
---@field public id? string used for identifying the group in the tabline
---@field public name? string 'formatted name of the group'
---@field public display_name? string original name including special characters
---@field public matcher? fun(b: bufferlines.Buffer): boolean?
---@field public separator? GroupSeparators
---@field public priority? number
---@field public highlight? table<string, string>
---@field public icon? string
---@field public hidden? boolean
---@field public with? fun(Group, Group): bufferlines.Group
---@field auto_close boolean when leaving the group automatically close it

---@class bufferlines.RenderContext
---@field preferences bufferlines.Config
---@field current_highlights {[string]: string}
---@field tab bufferlines.TabElement
---@field is_picking boolean

---@class bufferlines.SegmentAttribute
---@field global boolean whether or not the attribute applies to other elements apart from the current one
---@field prefix string
---@field suffix string
---@field action? {kind: string, id: integer}
---@field extends number how many positions the attribute extends for

---@class bufferlines.Segment
---@field text string
---@field plain_text? string
---@field highlight string
---@field attr bufferlines.SegmentAttribute

---@class bufferlines.Section
---@field items bufferlines.Component[]
---@field length integer
---@field drop fun(self: bufferlines.Section, count: integer): bufferlines.Section?
---@field add fun(self: bufferlines.Section, item: bufferlines.Component)

---@class bufferlines.State
---@field components bufferlines.Component[]?
---@field current_element_index number?
---@field is_picking boolean?
---@field visible_components bufferlines.Component[]?
---@field __components bufferlines.Component[]?
---@field custom_sort number[]?
---@field left_offset_size number?
---@field right_offset_size number?

---@alias bufferlines.Sorter fun(buf_a: bufferlines.Buffer, buf_b: bufferlines.Buffer): boolean

---@class bufferlines.SorterOptions
---@field sort_by (string|function)?
---@field current_index integer?
---@field custom_sort boolean?
---@field prev_components bufferlines.TabElement[]
