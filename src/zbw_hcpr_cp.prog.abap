*&---------------------------------------------------------------------*
*& Report zbw_hcpr_cp
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbw_hcpr_cp.

DATA: lobj_hcpr_cp TYPE REF TO zcl_bw_hcpr_cp.

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

  ELSEIF pa_res = abap_true.

    lobj_hcpr_cp->restore_backup(
        iv_hcprnm = pa_hcpn
        iv_vers   = pa_vers
    ).

    IF pa_act = abap_true.
      lobj_hcpr_cp->activate_hcpr( iv_hcprnm = pa_hcpn ).
    ENDIF.

  ELSEIF pa_sho = abap_true.

    lobj_hcpr_cp->show_mapping( iv_hcprnm = pa_hcpn
                                iv_vers   = pa_vers ).
  ENDIF.
