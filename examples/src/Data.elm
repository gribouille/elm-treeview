module Data exposing (styles, model)

import Treeview as T

styles : T.Styles
styles = 
  [ T.Style "folder" ("folder yellow", "folder-open yellow") ""
  , T.Style "archive" ("file-archive-o", "file-archive-o") ""
  , T.Style "word" ("file-word-o", "file-word-o") "blue"
  , T.Style "image" ("file-image-o", "file-image-o") ""
  , T.Style "pdf" ("file-pdf-o", "file-pdf-o") "red"
  , T.Style "powerpoint" ("file-powerpoint-o", "file-powerpoint-o") "orange"
  , T.Style "excel" ("file-excel-o", "file-excel-o") "green"
  ]

model : T.Model
model = 
  [ T.node "pA" "Project A" "folder" False <| Just [
      T.node "pAg1" "Report 1" "folder" False <| Just [
        T.node "pAg1f1" "report_1_revA.pdf" "pdf" True Nothing,
        T.node "pAg1f2" "report_1_revB.pdf" "pdf" True Nothing,
        T.node "pAg1f3" "report_1_revC.pdf" "pdf" True Nothing
      ],
      T.node "pAg2" "Report 2" "folder" False <| Just [
        T.node "pAg2f1" "report_2_revA.pdf" "pdf" True Nothing,
        T.node "pAg2f2" "report_2_revB.pdf" "pdf" True Nothing
      ],
      T.node "pAf1" "lorem.doc" "word" True Nothing,
      T.node "pAf2" "ipsum.xls" "excel" True Nothing
    ],
    T.node "pB" "Keynote" "folder" False <| Just [
      T.node "pBf1" "workshop_part1.ppt" "powerpoint" True Nothing,
      T.node "pBf2" "workshop_part2.ppt" "powerpoint" True Nothing,
      T.node "pBf3" "image1.png" "image" True Nothing,
      T.node "pBf4" "image2.ppt" "image" True Nothing,
      T.node "pBf5" "image3.ppt" "image" True Nothing,
      T.node "pBf5" "image4.ppt" "image" True Nothing
    ]
  ]