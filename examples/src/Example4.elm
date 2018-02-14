module Example4 exposing (main)

import Html as H
import Html.Events as HE
import Treeview
import Data exposing (styles, model)

type alias Model = Treeview.Model

type Msg
  = OnTreeview Treeview.Msg
  | ToggleAll

config : Treeview.Config
config =
  Treeview.default styles


update : Msg -> Model -> Model
update msg model =
  case msg of
    OnTreeview msgTreeview -> Treeview.update msgTreeview model
    ToggleAll -> Treeview.toggleAll model


view : Model -> H.Html Msg
view model =
  H.div []
  [ viewToolbar ToggleAll
  , H.map OnTreeview <| Treeview.view config model ]


viewToolbar : msg -> H.Html msg
viewToolbar tg =
    H.div []
    [ H.button [ HE.onClick tg ] [ H.text "Toggle all" ]
    ]


main : Program Never Model Msg
main =
  H.beginnerProgram
    { model = model
    , view = view
    , update = update
    }
