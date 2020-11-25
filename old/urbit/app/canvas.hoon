::  canvas: A p2p drawings app
::
::    data:            scry command:
::    ------------    ----------------------------------------------
::    canvas           .^(canvas %gx /=canvas=/canvas/<ship>/<canvas>/noun)
::    gallery          .^((list canvas) %gx /=canvas=/gallery/noun)
::
/-  *canvas, *chat-store
/+  *server, default-agent, verb, *canvas, *canvas-templates, base=base64
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
/=  canvas-svg
  /^  (map knot @)
  /:  /===/app/canvas/svg  /_  /svg/
::  State
::
=>  |%
    +$  card  card:agent:gall
    ::
    +$  state-zero
      $:  %0
          gallery=(map location canvas)
          buffer=(map @t [chunks=(list @t) svg=(unit [@t path])])
      ==
    --
::
=|  state-zero
=*  state  -
::  Main
::
%+  verb  |
^-  agent:gall
=<  |_  =bowl:gall
    +*  this         .
        canvas-core  +>
        cc           ~(. canvas-core bowl)
        def          ~(. (default-agent this %|) bowl)
    ::
    ++  on-init  on-init:def
      ::  FIXME: attemp to have a watcher on the images folder
      ::
      :: ^-  (quip card _this)
      :: :_  this
      :: =/  sing  [%sing %t  [%da now.bowl] /app/canvas/images]
      :: =/  next  [%next %t [%da now.bowl] /app/canvas/images]
      :: :~  [%pass /read/images %arvo %c %warp our.bowl q.byk.bowl `sing]
      ::     [%pass /read/images %arvo %c %warp our.bowl q.byk.bowl `next]
      :: ==
    ::
    ++  on-save
      !>(state)
    ::
    ++  on-load
      |=  old=vase
      ^-  (quip card _this)
      [~ this(state !<(state-zero old))]
    ::
    ++  on-poke
      |=  [=mark =vase]
      ^-  (quip card _this)
      ?+    mark  (on-poke:def mark vase)
          %canvas-action
        =^  cards  state
          (handle-canvas-action:cc !<(canvas-action vase))
        [cards this]
      ==
    ::
    ++  on-watch
      |=  =path
      ^-  (quip card _this)
      :_  this
      ?+    path  ~|([%peer-canvas-strange path] !!)
          [%updates ~]  ~
      ::
          [%canvas ^]
        =^  cards  state
           (send-init-canvas:cc i.t.path)
         cards
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
              %canvas-update
            (handle-canvas-update:cc !<(canvas-update vase))
          ==
        [cards this]
      ==
    ::
    ++  on-arvo
      |=  [=wire =sign-arvo]
      ^-  (quip card _this)
      ?:  ?=(%bound +<.sign-arvo)
        [~ this]
      ?+    wire  (on-arvo:def wire sign-arvo)
        ::  FIXME: this should be called when a new image is created
        ::   [%read %images ~]
        :: ?>  ?=([?(%b %c) %writ *] sign-arvo)
        :: =/  rot=riot:clay  +>.sign-arvo
        :: ?>  ?=(^ rot)
        :: [(send-updated-files u.rot) this]
      ::
          [%write @t @t @t ~]
        =^  cards  state
          (check-file i.t.wire i.t.t.wire i.t.t.t.wire (scot %da now.bowl))
        [cards this]
      ==
    ::
    ++  on-leave  on-leave:def
    ::
    ++  on-peek
      |=  =path
      ^-  (unit (unit cage))
      ?+    path  (on-peek:def path)
          [%x %canvas @t @t ~]
        ``noun+!>((~(got by gallery) (extract-location t.t.path)))
      ::
          [%x %gallery ~]
        ``noun+!>(~(val by gallery))
      ==
    ::
    ++  on-fail   on-fail:def
    --
::
|_  =bowl:gall
++  our-beak
  ::  doing (scot %da now.bowl) here consistently returned ~2000.1.1 (?)
  ::
  /(scot %p our.bowl)/[q.byk.bowl]/(scot %da now.bowl)
::
++  extract-location
  |=  =path
  ^-  [ship @t]
  ?>  ?=([@t @t ~] path)
  :_  i.t.path
  (rash i.path ;~(pfix sig fed:ag))
::
++  subscribe
  |=  [=ship name=@t]
  ^-  card
  :*  %pass
      /subscribe/(scot %p ship)/(scot %tas name)
      %agent
      [ship %canvas]
      %watch
      /canvas/(scot %tas name)
  ==
::
++  leave
  |=  [=ship name=@t]
  ^-  card
  :*  %pass
      /subscribe/(scot %p ship)/(scot %tas name)
      %agent
      [ship %canvas]
      %leave
      ~
  ==
::
++  send-init-canvas
  |=  name=@t
  ^-  (quip card _state)
  =/  canvas=(unit canvas)  (~(get by gallery) [our.bowl name])
  ?~  canvas  `state
  ?:  private.metadata.u.canvas
    ~|([%subs-not-allowed name] !!)
  :_  state
  [%give %fact ~ %canvas-update !>([%load name u.canvas])]~
::
++  send-paint-update
  |=  [name=@t strokes=(list stroke) who=@p]
  ^-  card
  :*  %give
      %fact
      [/canvas/(scot %tas name)]~
      %canvas-update
      !>([%paint our.bowl name strokes who])
  ==
::
++  check-file
  |=  [host=@t file=@t type=@t time=@t]
  ^-  (quip card _state)
  ::  doing (scot %da now.bowl) here consistently produced ~2000.1.1 (?)
  ::
  =/  paths=(list path)
    .^  (list path)
        %ct
        /=home/(same time)/app/canvas/images/(same type)/(same file)
    ==
  ?~  paths
    =/  location=wire  /write/(same host)/(same file)
    ::  set up timer again
    ::  (!) this could be dangerous (infinite loop...)
    :_  state
    [%pass location %arvo %b %wait (add now.bowl ~s10)]~
  =/  =ship  (rash host ;~(pfix sig fed:ag))
  =/  =canvas  (~(got by gallery) [ship file])
  =.  saved.metadata.canvas  %.y
  :_  state(gallery (~(put by gallery) [[ship file] canvas]))
  [%give %fact [/updates]~ %canvas-view !>([%file file])]~
::
++  write-svg-file
  |=  file=@t
  ^-  (list card)
  =/  buffer=[* (unit [svg=@t =path])]  (~(got by buffer) file)
  =+  (need +.buffer)
  =/  contents=cage  [%svg !>(svg)]
  [%pass /write-file %arvo %c %info (foal:space:userlib path contents)]~
::
:: ++  send-updated-files
::   |=  ran=rant:clay
::   ^-  (list card)
::   ~&  "send-updated-files"
::   =/  next  [%next %t [%da now.bowl] /app/canvas/images]
::   =/  files  !>([%files !<((list path) q.r.ran)])
::   :~  [%give %fact [/updates]~ %canvas-view files]
::       [%pass /read/images %arvo %c %warp our.bowl q.byk.bowl `next]
::   ==
::
++  update-remote-canvas
  |=  [location=@p name=@t strokes=(list stroke)]
  ^-  card
  ?>  ?=(^ strokes)
  :*  %pass
      [%paint name ~]
      %agent
      [location %canvas]
      %poke
      %canvas-action
      !>([%paint location name strokes])
  ==
::
++  handle-canvas-action
  |=  act=canvas-action
  ^-  (quip card _state)
  |^
  ?+  -.act  !!
    %paint   (handle-paint +.act)
    %join    (handle-join +.act)
    %leave   (handle-leave +.act)
    %create  (handle-create +.act)
    %share   (handle-share +.act)
    %save    (handle-save +.act)
  ==
  ::
  ++  handle-paint
    |=  [location=@p name=@t strokes=(list stroke)]
    ^-  (quip card _state)
    (process-remote-paint location name strokes)
  ::
  ++  handle-join
    |=  [=ship name=@t]
    ^-  (quip card _state)
    ?>  (team:title our.bowl src.bowl)
    [[(subscribe ship name)]~ state]
  ::
  ++  handle-leave
    |=  [=ship name=@t]
    ^-  (quip card _state)
    ?>  (team:title our.bowl src.bowl)
    =/  =canvas  (~(got by gallery) [ship name])
    ::  the canvas becomes local
    ::
    =.  location.metadata.canvas  our.bowl
    :_  state(gallery (~(put by gallery) [ship name] canvas))
    :~  (leave ship name)
        [%give %fact [/updates]~ %canvas-view !>([%load name canvas])]
    ==
  ::
  ++  handle-create
    |=  =canvas
    ^-  (quip card _state)
    ?>  (team:title our.bowl src.bowl)
    =*  name  name.metadata.canvas
    =*  private  private.metadata.canvas
    =.  canvas
      %.  [canvas name our.bowl private]
      ?+  type.metadata.canvas  blank
        %mesh-welcome  tmdw
        %mesh-martian  martian
        %mesh-bitcoin  bitcoin
        %mesh-crypto   crypto
        %mesh-guy      guybrush
        %mesh-yc-hn    yc-hn
        %mesh-sigil    larsen
        %mesh-tile     tile
        %mesh-life     life
        %mesh-public   public
      ==
    =/  load=canvas-view  [%load name.metadata.canvas canvas]
    :-  [%give %fact [/updates]~ %canvas-view !>(load)]~
    %_    state
        gallery
      (~(put by gallery) [[our.bowl name.metadata.canvas] canvas])
    ==
  ::
  ++  handle-share
   |=  [name=@t chat=path type=image-type]
   ^-  (quip card _state)
   ?>  (team:title our.bowl src.bowl)
   :_  state
   ::  TODO: check if file has been created already?
   ::  now we disable share on browser if not
   ::
   =/  serial=@uvH  (shaf %msg-uid eny.bowl)
   =/  =hart:eyre  .^(hart:eyre %e /(scot %p our.bowl)/host/real)
   =/  port=(unit @ud)  q.hart
   =/  domain-port=tape
     ;:  weld
         ?:(p.hart "https://" "http://")
       ::
         ?-  -.r.hart
           %.y  (trip (en-turf:html p.r.hart))
           %.n  (slag 1 (scow %if p.r.hart))
         ==
      ::
        ":"
        ?~(port "" ((d-co:co 1) u.port))
     ==
   =/  =letter
     :-  %url
     %-  crip
     ::  TODO: add avg as option to preview in chat
     ::        for now, using png as an extension works
     ::
     "{domain-port}/~canvas/images/{(trip type)}/{(trip name)}.png"
   =/  =envelope  [serial *@ our.bowl now.bowl letter]
   :_  ~
   :*  %pass
       ~[%chat %share name]
       %agent
       [our.bowl %chat-hook]
       %poke
       %chat-action
       !>([%message chat envelope])
   ==
  ::
  ++  handle-save
    |=  [=ship file=@t chunk=@t last=? type=image-type]
    ^-  (quip card _state)
    ?>  (team:title our.bowl src.bowl)
    =/  temp=(unit [chunks=(list @t) *])  (~(get by buffer) file)
    ?.  last
      ::  %eyre was crashing when the svg was ~1MB
      ::  solution: send chunks and assemble them later
      ::
      :-  ~
      %_    state
          buffer
        %-  ~(put by buffer)
        :-  file
        :_  ~
        ?~  temp  [chunk]~
        (snoc chunks.u.temp chunk)
      ==
    =/  img=@t
      %-  crip
      (snoc ?~(temp ~ chunks.u.temp) chunk)
    =/  =path
      %+  weld
        /=home/(scot %da now.bowl)/app/canvas
      /images/(same type)/(same file)/(same type)
    =/  contents=cage
      :-  type
      ?.  =(%png type)
        !>(img)
      !>(q:(need (de:base img)))
    ::
    :: FIXME: attempt to have a watcher on the images directory
    ::
    :: =/  contents=cage  [%svg !>(img)]
    :: =+  dir=.^(arch %cy path)
    :: =/  create-or-replace=toro:clay
    ::   =,  space:userlib
    ::   ?~  fil.dir
    ::     (foal path contents)
    ::   (furl (fray path) (foal path contents))
    ::  we wait up to 5 minutes for the file to be written
    ::
    :: =/  =moat:clay  [da+now.bowl da+(add now.bowl ~m5) path]
    ::  the full svg file is temporarily stored in the buffer
    ::
    :: =.  buffer  (~(put by buffer) [file [~ `[img path]]])
    :: :_  state(buffer (~(put by buffer) [file [~ `[img path]]]))
    ::[%pass /file/(same file) %arvo %c %warp our.bowl %home ~ %many & moat]
    ::
    =/  location=wire  /write/(scot %p ship)/(same file)/(same type)
    :_  state(buffer (~(del by buffer) file))
    :~
        [%pass /write-file %arvo %c %info (foal:space:userlib path contents)]
        ::  this sets up a timer that will fire a "file-watcher"
        ::  that manually checks if the file has been created
        ::
        [%pass location %arvo %b %wait (add now.bowl ~s2)]
    ==
  --
::
++  handle-canvas-update
  |=  act=canvas-update
  ^-  (quip card _state)
  |^
  ?-  -.act
    %load    (handle-load +.act)
    %paint   (handle-paint +.act)
  ==
  ::
  ++  handle-load
    |=  [name=@t =canvas]
    ^-  (quip card _state)
    :_  state(gallery (~(put by gallery) [[src.bowl name] canvas]))
    [%give %fact [/updates]~ %canvas-view !>([%load name canvas])]~
  ::
  ++  handle-paint
    |=  [location=@p name=@t strokes=(list stroke) who=@p]
    ^-  (quip card _state)
    ?:  =(who our.bowl)
      ::  we receive an update for a stroke we originaly sent; discard
      ::
      `state
    (process-remote-paint location name strokes)
  --
::
++  process-remote-paint
  |=  [location=@p name=@t strokes=(list stroke)]
  ^-  (quip card _state)
  ?>  ?=(^ strokes)
  =/  canvas=(unit canvas)  (~(get by gallery) [location name])
  ?~  canvas  `state
  ?.  =(-.i.strokes -.u.canvas)  `state
  |^
  =*  meta  metadata.u.canvas
  :-  (send-effects strokes)
  %_    state
      gallery
    %+  ~(put by gallery)
      [location name]
    ^-  ^canvas
    ?-  -.u.canvas
      %mesh  [%mesh (update-mesh mesh.u.canvas strokes) meta]
      %draw  [%draw (update-draw draw.u.canvas strokes) meta]
    ==
  ==
  ::
  ++  send-effects
    |=  strokes=(list stroke)
    ^-  (list card)
    ?.  (team:title our.bowl src.bowl)
      ::  stroke from a remote ship
      ::
      =/  paint  !>([%paint location name strokes])
      :~  [%give %fact [/updates]~ %canvas-view paint]
          [(send-paint-update name strokes src.bowl)]
      ==
    ::  stroke from frontend
    ::
    ?:  =(location our.bowl)
      [(send-paint-update name strokes our.bowl)]~
    [(update-remote-canvas location name strokes)]~
  ::
  ++  update-mesh
    |=  [=mesh strokes=(list stroke)]
    ^-  ^mesh
    |-
    ?~  strokes  mesh
    ?>  ?=([%mesh @t =arc] i.strokes)
    %_    $
        strokes
      t.strokes
    ::
        mesh
      ?.  filled.arc.i.strokes
        (~(del by mesh) id.i.strokes)
      (~(put by mesh) [id.i.strokes arc.i.strokes])
    ==
  ::
  ++  update-draw
    |=  [=draw strokes=(list stroke)]
    ^-  ^draw
    |-
    ?~  strokes  draw
    ?>  ?=([%draw *] i.strokes)
    %_    $
        draw     (snoc draw form.i.strokes)
        strokes  t.strokes
    ==
  --
--
