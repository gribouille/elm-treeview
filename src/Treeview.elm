module Treeview exposing
    ( Config, Model, Node(..), Options, Styles, Style, Sort(..), default
    , node, nodeKey, nodeChildren, setNodeChildren, nodeTitle
    , toggleNode, setNodeVisible, nodeVisible, toggleAll, toggle
    , Msg(..), update
    , view
    )

{-| A customizable ELM treeview component.

Usage example:

    import Html
    import Treeview exposing (..)

    model : Model
    model = ...     -- see Model documentation

    styles : Styles
    styles = ...    -- see Styles documentation

    config : Config
    config = default styles

    main : Program Never Model Msg
    main =
      Html.beginnerProgram
        { model = model
        , view = view config
        , update = update
        }


## Model

@docs Config, Model, Node, Options, Styles, Style, Sort, default
@docs node, nodeKey, nodeChildren, setNodeChildren, nodeTitle
@docs toggleNode, setNodeVisible, nodeVisible, toggleAll, toggle


## Messages

@docs Msg, update


## View

@docs view

-}

import Html as H
import Html.Attributes as HA
import Html.Events as HE
import Json.Decode as Decode



-- MODEL


{-| Configure the treeview component.

Options:

  - `checkbox.enable`: activate the checkbox selection for each node.
  - `checkbox.multiple`: multiple nodes can be selected.
  - `checkbox.cascade`: enable the cascading selection (the children node will selected if the parent is selected).
  - `search.enable`: activate the search toolbar.
  - `sort`: sort the nodes (see `Sort` for more details).
  - `look.theme`: apply the theme.
  - `look.styles`: define the styles (CSS class and icons) for nodes.

Use default to get a default configuration and set a specific options.

Example:

    config : Config
    config =
        let
            d =
                default styles
        in
        { d | search = { enable = True } }

-}
type alias Config =
    { checkbox :
        { enable : Bool
        , multiple : Bool
        , cascade : Bool
        }
    , search :
        { enable : Bool

        -- TODO: add search options
        }
    , sort : Sort
    , look :
        { theme : String
        , styles : Styles
        }
    }


{-| Model of treeview.

Example:

    model : Model
    model =
        [ T.node "pA" "Project A" "folder" False <|
            Just
                [ T.node "pAg1" "Report 1" "folder" False <|
                    Just
                        [ T.node "pAg1f1" "report_1_revA.pdf" "pdf" True Nothing
                        , T.node "pAg1f2" "report_1_revB.pdf" "pdf" True Nothing
                        , T.node "pAg1f3" "report_1_revC.pdf" "pdf" True Nothing
                        ]
                , T.node "pAg2" "Report 2" "folder" False <|
                    Just
                        [ T.node "pAg2f1" "report_2_revA.pdf" "pdf" True Nothing
                        , T.node "pAg2f2" "report_2_revB.pdf" "pdf" True Nothing
                        ]
                , T.node "pAf1" "lorem.doc" "word" True Nothing
                , T.node "pAf2" "ipsum.xls" "excel" True Nothing
                ]
        , T.node "pB" "Keynote" "folder" False <|
            Just
                [ T.node "pBf1" "workshop_part1.ppt" "powerpoint" True Nothing
                , T.node "pBf2" "workshop_part2.ppt" "powerpoint" True Nothing
                , T.node "pBf3" "image1.png" "image" True Nothing
                , T.node "pBf4" "image2.ppt" "image" True Nothing
                , T.node "pBf5" "image3.ppt" "image" True Nothing
                , T.node "pBf5" "image4.ppt" "image" True Nothing
                ]
        ]

-}
type alias Model =
    List Node


{-| Node is an item of treeview.

Each node has:

  - an unique key
  - a title
  - a list of options (see `Options`)
  - maybe list of children.

-}
type Node
    = Node Key Title Options Children


{-| Define the option of current node.

Options:

  - `style`: node style defined in `Config.look.styles`
  - `selectable`: `True` if the node is clickable
  - `opened`: `True` if the children are visibles
  - `disabled`: to disable the node (children handle and node selection)
  - `visible`: to hide the node
  - `checked`: to select the node (required `Config.checkbox.enable = true`).

-}
type alias Options =
    { style : StyleName
    , selectable : Selectable
    , opened : Opened
    , disabled : Disabled
    , visible : Visible
    , checked : Checked
    }


{-| List of node's styles.

Example:

    styles : Styles
    styles =
        [ T.Style "folder" ( "folder yellow", "folder-open yellow" ) ""
        , T.Style "archive" ( "file-archive-o", "file-archive-o" ) ""
        , T.Style "word" ( "file-word-o", "file-word-o" ) "blue"
        , T.Style "image" ( "file-image-o", "file-image-o" ) ""
        , T.Style "pdf" ( "file-pdf-o", "file-pdf-o" ) "red"
        , T.Style "powerpoint" ( "file-powerpoint-o", "file-powerpoint-o" ) "orange"
        , T.Style "excel" ( "file-excel-o", "file-excel-o" ) "green"
        ]

-}
type alias Styles =
    List Style


{-| Define the style of node.

Options:

  - `name`: a unique id of style
  - `icon`: icon when the node is closed and when the node is opened
  - `class`: CSS class of node.

Note: the CSS class `opened` is added when the node is opened thus you can
defined a custom style in function of node state:

```scss
.myNodeStyle {
  ...
  .opened {...}
}
```

-}
type alias Style =
    { name : StyleName
    , icon : Icon
    , class : Class
    }


{-| Sort the node from the title:

  - `None` = no sort
  - `Asc` = ascending order
  - `Desc` = descending order

-}
type Sort
    = None
    | Asc
    | Desc


type alias StyleName =
    String


type alias Opened =
    Bool


type alias Visible =
    Bool


type alias Checked =
    Bool


type alias Disabled =
    Bool


type alias Key =
    String


type alias Title =
    String


type alias Icon =
    ( String, String )


type alias Class =
    String


type alias Selectable =
    Bool


type alias Expand =
    Bool


type alias Children =
    Maybe (List Node)


{-| Create a default `Config` in function of list of styles.
-}
default : Styles -> Config
default ls =
    { checkbox = { enable = False, multiple = False, cascade = False }
    , search = { enable = False }
    , sort = None
    , look = { theme = "default", styles = ls }
    }


{-| Shortcut to create a new `Node`.
-}
node : Key -> Title -> StyleName -> Selectable -> Children -> Node
node key title style selectable children =
    Node key title (Options style selectable True False True False) children



-- Node getters / setters


{-| Get the node key.
-}
nodeKey : Node -> Key
nodeKey (Node x _ _ _) =
    x


{-| Get the node title.
-}
nodeTitle : Node -> Title
nodeTitle (Node _ x _ _) =
    x


{-| Get the node children.
-}
nodeChildren : Node -> Children
nodeChildren (Node _ _ _ x) =
    x


{-| Get the node visibility.
-}
nodeVisible : Node -> Visible
nodeVisible (Node _ _ opt _) =
    opt.visible


{-| Toggle the node opening.
-}
toggleNode : Node -> Node
toggleNode (Node a b c d) =
    Node a b { c | opened = not c.opened } d


{-| Set the node children.
-}
setNodeChildren : Children -> Node -> Node
setNodeChildren children (Node a b c _) =
    Node a b c children


{-| Set the node visibility.
-}
setNodeVisible : Visible -> Node -> Node
setNodeVisible val (Node a b c d) =
    Node a b { c | visible = val } d



--  MESSAGES


{-| Messages of treeview:

  - `Toggle Key`: open / close a node
  - `Select Key`: click on the title of node
  - `Search String`: filter search
  - `ToggleCheck Multiple Cascade Key Value`: check/uncheck a node checkbox.

-}
type Msg
    = Toggle Key
    | Select Key
    | Search String
    | ToggleCheck Bool Bool Key Bool -- Multiple Cascade Key Value


{-| The treeview update function.
-}
update : Msg -> Model -> Model
update msg model =
    case msg of
        Toggle key ->
            toggle key model

        Search val ->
            search val model

        ToggleCheck multiple cascade key value ->
            check multiple cascade key value model

        _ ->
            model



-- Update the options.checked value of nodes.


check : Bool -> Bool -> Key -> Bool -> Model -> Model
check multiple cascade key value =
    let
        freset =
            List.map (setNodesCheckedCascade False)

        fset =
            List.map (setNodeChecked cascade key value)
    in
    if multiple then
        fset

    else
        freset >> fset



-- Search the node and set the checked option. If cascade is True, the same
-- value is applied to children.


setNodeChecked : Bool -> Key -> Checked -> Node -> Node
setNodeChecked cascade key val (Node k t opt children) =
    if k == key then
        let
            options =
                { opt | checked = not val }
        in
        if cascade then
            Node k t options <| Maybe.map (List.map (setNodesCheckedCascade (not val))) children

        else
            Node k t options children

    else
        Node k t opt <| Maybe.map (List.map (setNodeChecked cascade key val)) children



-- Set the option checked of node and these children.


setNodesCheckedCascade : Bool -> Node -> Node
setNodesCheckedCascade val (Node k t opt children) =
    let
        options =
            { opt | checked = val }
    in
    case children of
        Nothing ->
            Node k t options Nothing

        Just cs ->
            Node k t options <| Just (List.map (setNodesCheckedCascade val) cs)



-- Filter the treeview nodes in function of search pattern.


search : String -> Model -> Model
search val =
    List.map (searchItem val)



{- Rules:
   - ignore the case
   - start the filtering by the children
   - if all children didn't match and the node does not match, the node is hidden.
-}


searchItem : String -> Node -> Node
searchItem val (Node k t opt c) =
    case c of
        Nothing ->
            let
                pattern =
                    String.toLower val

                title =
                    String.toLower t

                match =
                    String.contains pattern title

                options =
                    { opt | visible = match }
            in
            Node k t options Nothing

        Just cs ->
            let
                children =
                    List.map (searchItem val) cs

                allHide =
                    List.all (nodeVisible >> not) children

                options =
                    { opt | visible = not allHide }
            in
            Node k t options (Just children)


{-| Toggle the opened options.
-}
toggle : Key -> Model -> Model
toggle key nodes =
    List.map (toggleItem key) nodes


toggleItem : Key -> Node -> Node
toggleItem key n =
    if nodeKey n == key then
        toggleNode n

    else
        let
            children =
                nodeChildren n
        in
        case children of
            Nothing ->
                n

            Just c ->
                setNodeChildren (Just (List.map (toggleItem key) c)) n


{-| Toggle all items.
-}
toggleAll : Model -> Model
toggleAll =
    List.map toggleAllItem


toggleAllItem : Node -> Node
toggleAllItem n =
    let
        children =
            nodeChildren n
                |> Maybe.andThen (Just << List.map toggleAllItem)
    in
    toggleNode n
        |> setNodeChildren children



--  VIEW


{-| Tree treeview view function.
-}
view : Config -> Model -> H.Html Msg
view config model =
    H.div [ HA.class ("treeview " ++ config.look.theme) ]
        [ optional config.search.enable (viewSearch config)
        , H.ul [ HA.class "root" ] <| List.map (viewItem config) model
        ]



-- Search toolbar view.


viewSearch : Config -> H.Html Msg
viewSearch config =
    H.div [ HA.class "search" ]
        [ H.input
            [ HA.type_ "text"
            , HE.onInput Search
            , HA.placeholder "search"
            ]
            []
        ]



-- Node view.


viewItem : Config -> Node -> H.Html Msg
viewItem config n =
    optional (nodeVisible n) (viewItem_ config n)


viewItem_ : Config -> Node -> H.Html Msg
viewItem_ config (Node key title opt children) =
    let
        style =
            find ((==) opt.style << .name) config.look.styles

        icon =
            Maybe.map .icon style

        class =
            Maybe.map .class style

        ( iconC, iconO ) =
            Maybe.withDefault ( "", "" ) icon

        cls =
            Maybe.withDefault "" class

        ic =
            if opt.opened then
                iconO

            else
                iconC

        cl =
            "item "
                ++ cls
                ++ (case children of
                        Nothing ->
                            " last"

                        _ ->
                            if opt.opened then
                                " opened"

                            else
                                ""
                   )

        base =
            [ optional (children /= Nothing) <|
                H.a
                    [ HA.class "toggle"
                    , onClickEvent (Toggle key)
                    , HA.disabled opt.disabled
                    ]
                    [ awesome (clsTick opt.opened) ]
            , optional config.checkbox.enable <|
                viewItemCheckbox config.checkbox.multiple config.checkbox.cascade opt.checked key
            , optional (ic /= "") (awesome ic)
            , if opt.selectable then
                H.a
                    [ onClickEvent (Select key)
                    , HA.disabled opt.disabled
                    ]
                    [ H.text title ]

              else
                H.span [] [ H.text title ]
            ]
    in
    if opt.opened then
        case children of
            Nothing ->
                H.li [ HA.class cl ] base

            Just c ->
                H.li [ HA.class cl ] <|
                    List.append base [ H.ul [ HA.class "group" ] <| List.map (viewItem config) c ]

    else
        H.li [ HA.class cl ] base


onClickEvent : msg -> H.Attribute msg
onClickEvent evt =
    HE.custom "click" <|
        Decode.succeed
            { message = evt
            , stopPropagation = True
            , preventDefault = True
            }



-- Node checkbox view.


viewItemCheckbox : Bool -> Bool -> Bool -> Key -> H.Html Msg
viewItemCheckbox multiple cascade value key =
    H.input
        [ HA.type_ "checkbox"
        , HA.checked value
        , HE.onClick (ToggleCheck multiple cascade key value)
        ]
        []



-- UTILS
-- Get the font-awesome icons of handles.


clsTick : Bool -> String
clsTick x =
    case x of
        True ->
            "angle-down"

        -- "minus-square-o"
        False ->
            "angle-right"



-- "plus-square-o"
-- font-awesome shortcut.


awesome : String -> H.Html msg
awesome name =
    H.i [ HA.class ("fa fa-" ++ name), HA.attribute "aria-hidden" "true" ] []



-- find for List.


find : (a -> Bool) -> List a -> Maybe a
find predicate list =
    case list of
        [] ->
            Nothing

        first :: rest ->
            if predicate first then
                Just first

            else
                find predicate rest



-- Optional HTML component rendering.


optional : Bool -> H.Html msg -> H.Html msg
optional cond elt =
    if cond then
        elt

    else
        H.text ""
