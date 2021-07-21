::  canvas-view: A Canvas app for Urbit
::
/-  *canvas, *chat-store
/+  *server, default-agent, verb, *canvas, *canvas-templates
::
/=  index
  /^  octs
  /;  as-octs:mimes:html
  /:  /===/app/canvas/index
  /|  /html/
      /~  ~
  ==
/=  tile-js
  /^  octs
  /;  as-octs:mimes:html
  /:  /===/app/canvas/js/tile
  /|  /js/
      /~  ~
  ==
/=  script
  /^  octs
  /;  as-octs:mimes:html
  /:  /===/app/canvas/js/index
  /|  /js/
      /~  ~
  ==
/=  style
  /^  octs
  /;  as-octs:mimes:html
  /:  /===/app/canvas/css/index
  /|  /css/
      /~  ~
  ==
/=  canvas-png
  /^  (map knot @)
  /:  /===/app/canvas/img  /_  /png/
/=  canvas-images-png
  /^  (map knot @)
  /:  /===/app/canvas/images/png  /_  /png/
/=  canvas-images-svg
  /^  (map knot @)
  /:  /===/app/canvas/images/svg  /_  /svg/
/=  canvas-maps
  /^  (map knot @)
  /:  /===/app/canvas/map  /_  /atom/
::  State
::
=>  |%
    +$  card  card:agent:gall
    ::
    +$  state
      $%  [%0 state-zero]
      ==
    ::
    +$  state-zero
      $:  ~
      ==
    --
::
=|  state-zero
=*  state  -
::  Main
::
^-  agent:gall
=<  |_  =bowl:gall
    +*  this  .
        cv    ~(. +> bowl)
        def   ~(. (default-agent this %|) bowl)
    ::
    ++  on-init
      ^-  (quip card _this)
      :_  this
      :~  [%pass /bind/canvas %arvo %e %connect [~ /'~canvas'] %canvas-view]
          [%pass /updates %agent [our.bowl %canvas] %watch /updates]
        ::
          ::  Add tile to %launch
          ::
          :*  %pass
              /launch/canvas
              %agent
              [our.bowl %launch]
              %poke
              %launch-action
              !>([%add %canvas-view /canvastile '/~canvas/js/tile.js'])
     ==   ==
    ::
    ++  on-poke
      |=  [=mark =vase]
      ^-  (quip card _this)
      ?>  (team:title our.bowl src.bowl)
      ?+    mark  (on-poke:def mark vase)
          %json
        =^  cards  state
          (handle-json:cv !<(json vase))
        [cards this]
      ::
          %handle-http-request
        =+  !<([eyre-id=@ta =inbound-request:eyre] vase)
        =+  url=(parse-request-line url.request.inbound-request)
        :_  this
        %+  give-simple-payload:app  eyre-id
        (poke-handle-http-request:cv inbound-request site.url)
      ::
          %canvas-view
        =^  cards  state
          (handle-canvas-view:cv !<(canvas-view vase))
        [cards this]
      ==
    ::
    ++  on-watch
      |=  =path
      ^-  (quip card _this)
      :_  this
      ?+    path  ~|([%peer-canvas-strange path] !!)
          [%canvastile ~]
        [%give %fact ~ %json !>(*json)]~
      ::
          [%primary *]
        =^  cards  state
          (handle-canvas-view:cv [%init ~])
        cards
      ::
          [%http-response *]
        ~
      ==
    ::
    ++  on-agent
      |=  [=wire =sign:agent:gall]
      ^-  (quip card _this)
      ?-    -.sign
          %poke-ack   (on-agent:def wire sign)
          %watch-ack  (on-agent:def wire sign)
          %kick       (on-agent:def wire sign)
      ::
          %fact
        =^  cards  state
          =*  vase  q.cage.sign
          ^-  (quip card _state)
          ?+    p.cage.sign  ~|([%canvas-bad-update-mark wire vase] !!)
              %canvas-view
            (handle-view-update:cv !<(canvas-view q.cage.sign))
          ==
        [cards this]
      ==
    ::
    ++  on-arvo
      |=  [=wire =sign-arvo]
      ^-  (quip card _this)
      ?:  ?=(%bound +<.sign-arvo)
        [~ this]
      (on-arvo:def wire sign-arvo)
    ::
    ++  on-save   on-save:def
    ++  on-load   on-load:def
    ++  on-leave  on-leave:def
    ++  on-peek   on-peek:def
    ++  on-fail   on-fail:def
    --
::
|_  =bowl:gall
++  gallery-scry
  .^  (list canvas)
    %gx
    (scot %p our.bowl)
    %canvas
    (scot %da now.bowl)
    /gallery/noun
  ==
::
++  canvas-scry
  |=  name=@t
  ^-  canvas-view-response
  :+  %load  name
  .^  canvas
    %gx
    (scot %p our.bowl)
    %canvas
    (scot %da now.bowl)
    ~[%canvas name %noun]
  ==
::
++  chats-scry
  ^-  (list path)
  %~  tap   by
  .^  (set path)
    %gx
    (scot %p our.bowl)
    %chat-store
    (scot %da now.bowl)
    /keys/noun
  ==
::
++  send-canvas-action
  |=  [=wire act=canvas-action]
  ^-  card
  [%pass wire %agent [our.bowl %canvas] %poke %canvas-action !>(act)]
::
++  send-frontend
  |=  =json
  ^-  (list card)
  [%give %fact [/primary]~ %json !>(json)]~
::
++  handle-json
  |=  jon=json
  ^-  (quip card _state)
  ?>  (team:title our.bowl src.bowl)
  ::  Actions originated on the frontend
  ::
  (handle-canvas-view (json-to-canvas-view jon))
::
++  handle-canvas-view
  |=  act=canvas-view
  ^-  (quip card _state)
  :_  state
  |^
  ?+  -.act  !!
    %init    handle-init
    %paint   (handle-paint +.act)
    %join    (handle-join +.act)
    %leave   (handle-leave +.act)
    %create  (handle-create +.act)
    %share   (handle-share +.act)
    %save    (handle-save +.act)
  ==
  ::
  ++  handle-init
    ^-  (list card)
    %-  send-frontend
    %-  canvas-view-response-to-json
    [%init-frontend [(welcome ~ 'welcome' our.bowl &) gallery-scry] chats-scry]
  ::
  ++  handle-paint
    |=  [location=@p name=@t strokes=(list stroke)]
    ^-  (list card)
    [(send-canvas-action [%paint name ~] [%paint +<])]~
  ::
  ++  handle-join
    |=  [=ship canvas-name=@t]
    ^-  (list card)
    :_  ~
    %+  send-canvas-action
      [%join (scot %p ship) canvas-name ~]
    [%join +<]
  ::
  ++  handle-leave
    |=  [=ship canvas-name=@t]
    ^-  (list card)
    :_  ~
    %+  send-canvas-action
      [%leave (scot %p ship) canvas-name ~]
    [%leave +<]
  ::
  ++  handle-create
   |=  =canvas
   ^-  (list card)
   :_  ~
   %+  send-canvas-action
     [%create name.metadata.canvas ~]
   ^-  canvas-action
   :-  %create
   ?-  -.canvas
     %draw  [%draw ~ metadata.canvas]
     %mesh  [%mesh ~ metadata.canvas]
   ==
  ::
  ++  handle-share
   |=  [name=@t =path =image-type]
   ^-  (list card)
   [(send-canvas-action [%share name ~] [%share +<])]~
  ::
  ++  handle-save
    |=  [=ship name=@t svg=@t last=? =image-type]
    ^-  (list card)
    [(send-canvas-action [%save name ~] [%save +<])]~
  --
::
++  handle-view-update
  |=  act=canvas-view
  ^-  (quip card _state)
  :_  state
  |^
  ?+  -.act  !!
    %paint   (handle-paint +.act)
    %load    (handle-load +.act)
    %file    (handle-file +.act)
  ==
  ::
  ++  handle-paint
    |=  [location=@p name=@t strokes=(list stroke)]
    ^-  (list card)
    %-  send-frontend
    (canvas-view-response-to-json [%paint +<])
  ::
  ++  handle-load
    |=  [name=@t =canvas]
    ^-  (list card)
    (send-frontend (canvas-view-response-to-json [%load +<]))
  ::
  ++  handle-file
    |=  file=@t
    ^-  (list card)
    (send-frontend (canvas-view-response-to-json [%file file]))
  --
::
++  poke-handle-http-request
  |=  [=inbound-request:eyre url=(list @t)]
  ^-  simple-payload:http
  |^
  ?:  ?=([%'~canvas' %images image-type @t *] url)
    (handle-canvas-image-call i.t.t.url i.t.t.t.url)
  %+  require-authorization:app  inbound-request
  handle-auth-call
  ::
  ++  handle-canvas-image-call
    |=  [type=image-type file=@t]
    ^-  simple-payload:http
    =/  [response=_png-response:gen canvas-img=(unit @)]
      ?-    type
          %png
        :-  png-response:gen
        (~(get by canvas-images-png) file)
      ::
          %svg
        :-  svg-response:gen
        (~(get by canvas-images-svg) file)
      ==
    ?~  canvas-img
      not-found:gen
    (response (as-octs:mimes:html u.canvas-img))
  ::
  ++  handle-auth-call
    |=  =inbound-request:eyre
    ^-  simple-payload:http
    =/  url=request-line
      (parse-request-line url.request.inbound-request)
    ?+  site.url  not-found:gen
      [%'~canvas' %css %index ~]  (css-response:gen style)
      [%'~canvas' %js %tile ~]    (js-response:gen tile-js)
      [%'~canvas' %js %index ~]   (js-response:gen script)
      [%'~canvas' %map @t *]      (handle-json-call i.t.t.site.url)
      [%'~canvas' %img @t *]      (handle-img-call i.t.t.site.url)
      [%'~canvas' *]              (html-response:gen index)
    ==
  ::
  ++  handle-img-call
    |=  name=@t
    ^-  simple-payload:http
    =/  img  (~(get by canvas-png) name)
    ?~  img
      not-found:gen
    (png-response:gen (as-octs:mimes:html u.img))
  ::
  ++  handle-json-call
    |=  name=@t
    ^-  simple-payload:http
    =/  json  (~(get by canvas-maps) name)
    ?~  json
      not-found:gen
    (json-response:gen (as-octs:mimes:html u.json))
  --
--
