#include <X11/XF86keysym.h>
#include <X11/keysymdef.h>

/* Taken from https://github.com/djpohly/dwl/issues/466 */
#define COLOR(hex)                                                             \
  {                                                                            \
    ((hex >> 24) & 0xFF) / 255.0f, ((hex >> 16) & 0xFF) / 255.0f,              \
        ((hex >> 8) & 0xFF) / 255.0f, (hex & 0xFF) / 255.0f                    \
  }
/* appearance */
static const int sloppyfocus = 1; /* focus follows mouse */
static const int bypass_surface_visibility =
    0; /* 1 means idle inhibitors will disable idle tracking even if it's
          surface isn't visible  */
static const unsigned int borderpx = 3; /* border pixel of windows */
static const float rootcolor[] = COLOR(0x222222ff);
static const float bordercolor[] = COLOR(0x444444ff);
static const float focuscolor[] = COLOR(0x005577ff);
static const float urgentcolor[] = COLOR(0xff0000ff);
/* This conforms to the xdg-protocol. Set the alpha to zero to restore the old
 * behavior */
static const float fullscreen_bg[] = {0.1f, 0.1f, 0.1f,
                                      1.0f}; /* You can also use glsl colors */

/* tagging - TAGCOUNT must be no greater than 31 */
#define TAGCOUNT (9)

/* logging */
static int log_level = WLR_ERROR;

/* NOTE: ALWAYS keep a rule declared even if you don't use rules (e.g leave at
 * least one example) */
static const Rule rules[] = {
    /* app_id             title       tags mask     isfloating   monitor */
    /* examples: */
    {"Gimp_EXAMPLE", NULL, 0, 1,
     -1}, /* Start on currently visible tags floating, not tiled */
};

/* layout(s) */
static const Layout layouts[] = {
    /* symbol     arrange function */
    {"[]=", tile},
    {"><>", NULL}, /* no layout function means floating behavior */
    {"[M]", monocle},
};

/* monitors */
/* mfact: sets the factor of master area size compared to stack area * this is a
 * float value in the range of 0.05 to 0.95 * if set to -1 then the default
 * value as set in config.h is used. */
/*        split workspace by factor when creating new windows (see setmfact) */
/* nmaster: sets the number of clients in the master area * if set to -1 then
 * the default value as set in config.h is used */
/* (x=-1, y=-1) is reserved as an "autoconfigure" monitor position indicator
 * WARNING: negative values other than (-1, -1) cause problems with Xwayland
 * clients https://gitlab.freedesktop.org/xorg/xserver/-/issues/899
 */
/* NOTE: ALWAYS add a fallback rule, even if you are completely sure it won't be
 * used */
static const MonitorRule monrules[] = {
    /* name       mfact  nmaster scale layout       rotate/reflect x    y */
    /* defaults */
    {NULL, 0.50f, 1, 1.0f, &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL, -1, -1},
    /* Hi-DPI laptop monitor */
    {"eDP-1", 0.55f, 1, 1.2f, &layouts[0], WL_OUTPUT_TRANSFORM_NORMAL, -1, -1},
};

/* keyboard */
static const struct xkb_rule_names xkb_rules = {
    /* can specify fields: rules, model, layout, variant, options */
    /* example:
    .options = "ctrl:nocaps",
    */
    .options = NULL,
};

static const int repeat_rate = 25;
static const int repeat_delay = 600;

/* Trackpad */
static const int tap_to_click = 1;
static const int tap_and_drag = 1;
static const int drag_lock = 1;
static const int natural_scrolling = 0;
static const int disable_while_typing = 1;
static const int left_handed = 0;
static const int middle_button_emulation = 0;
/* You can choose between:
LIBINPUT_CONFIG_SCROLL_NO_SCROLL
LIBINPUT_CONFIG_SCROLL_2FG
LIBINPUT_CONFIG_SCROLL_EDGE
LIBINPUT_CONFIG_SCROLL_ON_BUTTON_DOWN
*/
static const enum libinput_config_scroll_method scroll_method =
    LIBINPUT_CONFIG_SCROLL_2FG;

/* You can choose between:
LIBINPUT_CONFIG_CLICK_METHOD_NONE
LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS
LIBINPUT_CONFIG_CLICK_METHOD_CLICKFINGER
*/
static const enum libinput_config_click_method click_method =
    LIBINPUT_CONFIG_CLICK_METHOD_BUTTON_AREAS;

/* You can choose between:
LIBINPUT_CONFIG_SEND_EVENTS_ENABLED
LIBINPUT_CONFIG_SEND_EVENTS_DISABLED
LIBINPUT_CONFIG_SEND_EVENTS_DISABLED_ON_EXTERNAL_MOUSE
*/
static const uint32_t send_events_mode = LIBINPUT_CONFIG_SEND_EVENTS_ENABLED;

/* You can choose between:
LIBINPUT_CONFIG_ACCEL_PROFILE_FLAT
LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE
*/
static const enum libinput_config_accel_profile accel_profile =
    LIBINPUT_CONFIG_ACCEL_PROFILE_ADAPTIVE;
static const double accel_speed = 2.0;

/* You can choose between:
LIBINPUT_CONFIG_TAP_MAP_LRM -- 1/2/3 finger tap maps to left/right/middle
LIBINPUT_CONFIG_TAP_MAP_LMR -- 1/2/3 finger tap maps to left/middle/right
*/
static const enum libinput_config_tap_button_map button_map =
    LIBINPUT_CONFIG_TAP_MAP_LRM;

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd)                                                             \
  {                                                                            \
    .v = (const char *[]) { "/bin/sh", "-c", cmd, NULL }                       \
  }

/* commands */
// clang-format off
static const char *termcmd[] = { @termcmd@, NULL };
static const char *menucmd[] = { @menucmd@, NULL };
static const char *volupcmd[] = { @volupcmd@, NULL };
static const char *voldowncmd[] = { @voldowncmd@, NULL };
static const char *volmutecmd[] = { @volmutecmd@, NULL };
static const char *brupcmd[] = { @brupcmd@, NULL };
static const char *brdowncmd[] = { @brdowncmd@, NULL };
// clang-format on

#define SUPER WLR_MODIFIER_LOGO /* Windows/Super Key */
#define CTRL WLR_MODIFIER_CTRL
#define ALT WLR_MODIFIER_ALT
#define SHIFT WLR_MODIFIER_SHIFT
#define XKB(key) XKB_KEY_##key
#define XFK(key) XF86XK_##key
#define TAGKEYS(KEY, SKEY, TAG)                                                \
  {ALT, KEY, view, {.ui = 1 << TAG}},                                          \
      {ALT | CTRL, KEY, toggleview, {.ui = 1 << TAG}},                         \
      {ALT | SHIFT, SKEY, tag, {.ui = 1 << TAG}}, {                            \
    ALT | CTRL | SHIFT, SKEY, toggletag, { .ui = 1 << TAG }                    \
  }

static const Key keys[] = {
    /* Note that Shift changes certain key codes: c -> C, 2 -> at, etc. */
    /* modifier  key              function        argument */
    //{0, XKB(Super_L), spawn, {.v = menucmd}},

    // custom
    {ALT, XKB(space), spawn, {.v = menucmd}},
    {SUPER, XKB(space), togglefloating, {0}},
    {ALT, XKB(Return), togglefullscreen, {0}},
    {SUPER | SHIFT, XKB(plus), zoom, {0}},
    {ALT, XKB(Tab), focusstack, {.i = +1}},
    {ALT | SHIFT, XKB(Tab), focusstack, {.i = -1}},
    {SUPER, XKB(Up), setlayout, {.v = &layouts[2]}},
    {SUPER, XKB(Down), setlayout, {0}},
    {SUPER | SHIFT, XKB(Right), setmfact, {.f = +0.05f}},
    {SUPER | SHIFT, XKB(Left), setmfact, {.f = -0.05f}},
    {SUPER, XKB(q), killclient, {0}},

    // defaults
    {ALT, XKB(j), focusstack, {.i = +1}},
    {ALT, XKB(k), focusstack, {.i = -1}},
    {ALT, XKB(i), incnmaster, {.i = +1}},
    {ALT, XKB(d), incnmaster, {.i = -1}},
    {ALT, XKB(h), setmfact, {.f = -0.05f}},
    {ALT, XKB(l), setmfact, {.f = +0.05f}},
    {ALT | SHIFT, XKB(C), killclient, {0}},
    {ALT, XKB(t), setlayout, {.v = &layouts[0]}},
    {ALT, XKB(f), setlayout, {.v = &layouts[1]}},
    {ALT, XKB(m), setlayout, {.v = &layouts[2]}},
    {ALT, XKB(space), setlayout, {0}},
    {ALT | SHIFT, XKB(space), togglefloating, {0}},
    {ALT, XKB(e), togglefullscreen, {0}},
    {ALT, XKB(0), view, {.ui = ~0}},
    {ALT | SHIFT, XKB(parenright), tag, {.ui = ~0}},
    {ALT, XKB(comma), focusmon, {.i = WLR_DIRECTION_LEFT}},
    {ALT, XKB(period), focusmon, {.i = WLR_DIRECTION_RIGHT}},
    {ALT | SHIFT, XKB(less), tagmon, {.i = WLR_DIRECTION_LEFT}},
    {ALT | SHIFT, XKB(greater), tagmon, {.i = WLR_DIRECTION_RIGHT}},

    TAGKEYS(XKB(1), XKB(exclam), 0),
    TAGKEYS(XKB(2), XKB(at), 1),
    TAGKEYS(XKB(3), XKB(numbersign), 2),
    TAGKEYS(XKB(4), XKB(dollar), 3),
    TAGKEYS(XKB(5), XKB(percent), 4),
    TAGKEYS(XKB(6), XKB(asciicircum), 5),
    TAGKEYS(XKB(7), XKB(ampersand), 6),
    TAGKEYS(XKB(8), XKB(asterisk), 7),
    TAGKEYS(XKB(9), XKB(parenleft), 8),

    {0, XFK(AudioRaiseVolume), spawn, {.v = volupcmd}},
    {0, XFK(AudioLowerVolume), spawn, {.v = voldowncmd}},
    {0, XFK(AudioMute), spawn, {.v = volmutecmd}},
    {0, XFK(MonBrightnessUp), spawn, {.v = brupcmd}},
    {0, XFK(MonBrightnessDown), spawn, {.v = brdowncmd}},

    {ALT | SHIFT, XKB(Q), quit, {0}},
    {ALT | SHIFT, XKB(Return), spawn, {.v = termcmd}},

    /* Ctrl-Alt-Backspace and Ctrl-Alt-Fx used to be handled by X server */
    {WLR_MODIFIER_CTRL | WLR_MODIFIER_ALT, XKB_KEY_Terminate_Server, quit, {0}},
/* Ctrl-Alt-Fx is used to switch to another VT, if you don't know what a VT is
 * do not remove them.
 */
#define CHVT(n)                                                                \
  {                                                                            \
    WLR_MODIFIER_CTRL | WLR_MODIFIER_ALT, XKB_KEY_XF86Switch_VT_##n, chvt, {   \
      .ui = (n)                                                                \
    }                                                                          \
  }
    CHVT(1),
    CHVT(2),
    CHVT(3),
    CHVT(4),
    CHVT(5),
    CHVT(6),
    CHVT(7),
    CHVT(8),
    CHVT(9),
    CHVT(10),
    CHVT(11),
    CHVT(12),
};

static const Button buttons[] = {
    {SUPER, BTN_LEFT, moveresize, {.ui = CurMove}},
    {SUPER, BTN_MIDDLE, togglefloating, {0}},
    {SUPER, BTN_RIGHT, moveresize, {.ui = CurResize}},
};
#undef TAGKEYS
#undef XFK
#undef XKB
#undef SHIFT
#undef ALT
#undef CTRL
#undef SUPER
