REPORT zpo_alv_report.

TABLES: zpo_req.

DATA: lt_data TYPE TABLE OF zpo_req.

START-OF-SELECTION.

  SELECT * FROM zpo_req INTO TABLE lt_data.

  IF sy-subrc <> 0.
    WRITE: / 'No records found'.
    EXIT.
  ENDIF.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_structure_name = 'ZPO_REQ'
    TABLES
      t_outtab          = lt_data.
