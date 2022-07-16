*&---------------------------------------------------------------------*
*& Report zbw_hcpr_cp
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbw_hcpr_cp.

DATA: lobj_hcpr_cp TYPE REF TO zcl_bw_hcpr_cp,
      lv_timt      TYPE tzonref-tstampl,
      lv_tz        TYPE ttzz-tzone,
      lv_answer    TYPE i.

PARAMETERS: pa_hcpn TYPE rsohcprnm,
            pa_vers TYPE char10.

PARAMETERS: pa_bkp RADIOBUTTON GROUP rg1,
            pa_res RADIOBUTTON GROUP rg1,
            pa_sho RADIOBUTTON GROUP rg1.

PARAMETERS: pa_act AS CHECKBOX.

end-of-selection.

  lobj_hcpr_cp = NEW #(  ).

  IF pa_bkp = abap_true.

    lobj_hcpr_cp->create_backup( iv_hcprnm = pa_hcpn
                                 iv_vers = pa_vers ).

    MESSAGE 'Backup done succesfully' TYPE 'S'.

  ELSEIF pa_res = abap_true.

    SELECT SINGLE timt
    FROM ('ZBW_HCPR_CP')
    WHERE hcprnm = @pa_hcpn
    AND vers = @pa_vers
    INTO @lv_timt.

    IF sy-subrc <> 0.
      MESSAGE 'Error during version restore' TYPE 'E'.
    ENDIF.

    CALL FUNCTION 'GET_SYSTEM_TIMEZONE'
      IMPORTING
        timezone            = lv_tz
      EXCEPTIONS
        customizing_missing = 1
        OTHERS              = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    CONVERT TIME STAMP lv_timt TIME ZONE lv_tz
        INTO DATE DATA(lv_date) TIME DATA(lv_time).

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        text_question  = |Version Timestamp: { lv_date DATE = ISO } { lv_time TIME = ISO }.Proceed ?|
      IMPORTING
        answer         = lv_answer
      EXCEPTIONS
        text_not_found = 1
        OTHERS         = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    IF lv_answer = 1.

      lobj_hcpr_cp->restore_backup(
          iv_hcprnm = pa_hcpn
          iv_vers   = pa_vers
      ).

      IF pa_act = abap_true.
        lobj_hcpr_cp->activate_hcpr( iv_hcprnm = pa_hcpn ).
      ENDIF.

      MESSAGE 'Version restored succesfully' TYPE 'S'.

    ENDIF.

  ELSEIF pa_sho = abap_true.

    lobj_hcpr_cp->show_mapping( iv_hcprnm = pa_hcpn
                                iv_vers   = pa_vers ).
  ENDIF.
