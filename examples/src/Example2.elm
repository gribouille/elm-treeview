module Example2 exposing (main)

import Html
import Treeview as T
import Data exposing (styles, model)


config : T.Config
config = 
  let
    d = T.default styles
  in
    {d | search = { enable = True}}


main : Program Never T.Model T.Msg 
main =
  Html.beginnerProgram
    { model = model
    , view = T.view config
    , update = T.update 
    }
