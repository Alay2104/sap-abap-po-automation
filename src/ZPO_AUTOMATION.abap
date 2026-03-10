REPORT zpo_automation.

TABLES: zpo_req.


* Selection Screen

PARAMETERS:
  p_ven TYPE lifnr,
  p_mat TYPE matnr,
  p_qty TYPE menge_d,
  p_prc TYPE netpr.

SELECTION-SCREEN PUSHBUTTON /1(20) btn1 USER-COMMAND save.
SELECTION-SCREEN PUSHBUTTON /25(20) btn2 USER-COMMAND gen.

INITIALIZATION.
  btn1 = 'Save Request'.
  btn2 = 'Generate PO'.

START-OF-SELECTION.

  CASE sy-ucomm.
    WHEN 'SAVE'.
      PERFORM save_request.
    WHEN 'GEN'.
      PERFORM generate_po.
  ENDCASE.


* Save Request

FORM save_request.

  DATA: ls_req TYPE zpo_req.

  ls_req-req_id   = sy-datum && sy-uzeit.
  ls_req-vendor   = p_ven.
  ls_req-material = p_mat.
  ls_req-qty      = p_qty.
  ls_req-price    = p_prc.
  ls_req-status   = 'REQUESTED'.

  INSERT zpo_req FROM ls_req.

  IF sy-subrc = 0.
    WRITE: / 'Purchase Request Saved Successfully'.
  ELSE.
    WRITE: / 'Error Saving Request'.
  ENDIF.

ENDFORM.


* Generate Purchase Order
FORM generate_po.

  DATA: ls_req TYPE zpo_req.

  SELECT SINGLE * FROM zpo_req
    INTO ls_req
    WHERE status = 'REQUESTED'.

  IF sy-subrc <> 0.
    WRITE: / 'No pending requests found'.
    RETURN.
  ENDIF.

  DATA: lt_return TYPE TABLE OF bapiret2.

  CALL FUNCTION 'BAPI_PO_CREATE1'
    TABLES
      return = lt_return.

  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.

  ls_req-status = 'PO_CREATED'.
  MODIFY zpo_req FROM ls_req.

  WRITE: / 'Purchase Order Generated Successfully'.

ENDFORM.
