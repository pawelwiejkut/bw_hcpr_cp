*&---------------------------------------------------------------------*
*& Report zbw_hcpr_cp
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zbw_hcpr_cp_standalone.

CLASS zcl_bw_hcpr_cp DEFINITION DEFERRED.
CLASS zcl_bw_hcpr_cp DEFINITION
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_hcpr,
             hcprnm TYPE c LENGTH 30,
             vers   TYPE c LENGTH 10,
             xml_ui TYPE rsrawstring.
    TYPES: END OF ty_hcpr.

    TYPES: t_ty_hcpr TYPE STANDARD TABLE OF ty_hcpr WITH DEFAULT KEY.

    METHODS constructor.

    METHODS create_global_ddic.

    METHODS create_backup
      IMPORTING iv_hcprnm TYPE char30
                iv_vers   TYPE char10..

    METHODS restore_backup
      IMPORTING iv_hcprnm TYPE char30
                iv_vers   TYPE char10.

    METHODS show_mapping
      IMPORTING iv_hcprnm TYPE char30
                iv_vers   TYPE char10.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.
CLASS zcl_bw_hcpr_cp IMPLEMENTATION.

  METHOD create_global_ddic.

    TYPES: BEGIN OF t_tables,
             tablename TYPE string.
             INCLUDE   TYPE dd03p.
    TYPES: END OF t_tables.

    TYPES: t_ty_tables TYPE STANDARD TABLE OF t_tables WITH EMPTY KEY.

    DATA: lv_objname  TYPE ddobjname,
          lv_rc       LIKE sy-subrc,
          lv_obj_name TYPE tadir-obj_name,
          ls_dd02v    TYPE dd02v,
          ls_dd09l    TYPE dd09l,
          lv_exist    TYPE abap_bool,
          lt_dd03p    TYPE STANDARD TABLE OF dd03p WITH EMPTY KEY.

    FIELD-SYMBOLS: <ls_dd03p> LIKE LINE OF lt_dd03p.

    DATA(lt_tables) = VALUE t_ty_tables(
    ( tablename = 'ZBW_HCPR_CP' fieldname = 'HCPRNM' position ='0001'
    keyflag = abap_true datatype = 'CHAR' leng = '000030' )
    ( tablename = 'ZBW_HCPR_CP' fieldname = 'VERS' position ='0002'
    keyflag = abap_true datatype = 'CHAR' leng = '000010' )
    ( tablename = 'ZBW_HCPR_CP' fieldname = 'XML_UI' position ='0003'
     datatype = 'RSTR'  )
 ).

    ls_dd09l-tabname  = 'ZBW_HCPR_CP'.
    ls_dd09l-as4local = 'A'.
    ls_dd09l-tabkat   = '1'.
    ls_dd09l-tabart   = 'APPL1'.
    ls_dd09l-bufallow = 'N'.

    ls_dd02v-tabname    = 'ZBW_HCPR_CP'.
    ls_dd02v-ddlanguage = 'E'.
    ls_dd02v-tabclass   = 'TRANSP'.
    ls_dd02v-ddtext     = 'Generated by ZBWHCPR_CP'.
    ls_dd02v-contflag   = 'L'.
    ls_dd02v-exclass    = '1'.

    SELECT SINGLE @abap_true ##SUBRC_OK
    FROM dd02l
    INTO @lv_exist
    WHERE   tabname = 'ZBW_HCPR_CP'
    AND     as4local  = 'A'.

    CHECK lv_exist = abap_false.

    lv_objname = 'ZBW_HCPR_CP'.

    lt_dd03p = CORRESPONDING #( lt_tables  MAPPING tabname = tablename ).

    IF lv_exist = abap_false.

      CALL FUNCTION 'DDIF_TABL_PUT'
        EXPORTING
          name              = lv_objname
          dd02v_wa          = ls_dd02v
          dd09l_wa          = ls_dd09l
        TABLES
          dd03p_tab         = lt_dd03p
        EXCEPTIONS
          tabl_not_found    = 1
          name_inconsistent = 2
          tabl_inconsistent = 3
          put_failure       = 4
          put_refused       = 5
          OTHERS            = 6.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      CALL FUNCTION 'DDIF_TABL_ACTIVATE'
        EXPORTING
          name        = lv_objname
          auth_chk    = abap_false
        IMPORTING
          rc          = lv_rc
        EXCEPTIONS
          not_found   = 1
          put_failure = 2
          OTHERS      = 3.
      IF sy-subrc <> 0 OR lv_rc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.

      CLEAR lt_dd03p.

    ENDIF.

  ENDMETHOD.

  METHOD create_backup.

    SELECT SINGLE hcprnm, xml_ui
    FROM rsohcpr
    INTO @DATA(ls_rsohcpr)
    WHERE hcprnm = @iv_hcprnm
    AND objvers = 'A'.

    DATA(ls_hcprtab) = CORRESPONDING ty_hcpr( ls_rsohcpr ).
    ls_hcprtab-vers = iv_vers.

    INSERT ('ZBW_HCPR_CP') FROM ls_hcprtab.
    IF sy-subrc <> 0.
      MESSAGE 'Error during backup creation, check version' TYPE 'E'.
    ENDIF.

  ENDMETHOD.

  METHOD restore_backup.

    DATA: ls_hcprtab TYPE ty_hcpr.

    SELECT SINGLE * FROM
    ('ZBW_HCPR_CP')
    INTO @ls_hcprtab
    WHERE hcprnm = @iv_hcprnm
    AND vers = @iv_vers.

    IF sy-subrc <> 0.
      MESSAGE 'Error during backup restore, check version' TYPE 'E'.
    ENDIF.

    UPDATE rsohcpr
    SET xml_ui = ls_hcprtab-xml_ui
    WHERE hcprnm = ls_hcprtab-hcprnm.

    IF sy-subrc <> 0.
      MESSAGE 'Error during backup restore, check version' TYPE 'E'.
    ENDIF.

  ENDMETHOD.

  METHOD show_mapping.

    TYPES: BEGIN OF ty_output,
             infoprovider TYPE rsdodsobject,
             source       TYPE rsdiobjnm,
             target       TYPE rsohcprcolnm,
           END OF ty_output.

    DATA: lv_offset   TYPE i,
          ls_output   TYPE ty_output,
          lt_output   TYPE STANDARD TABLE OF ty_output,
          lt_xml_info TYPE TABLE OF smum_xmltb,
          lt_return   TYPE STANDARD TABLE OF bapiret2.

    SELECT SINGLE xml_ui
    FROM zbw_hcpr_cp
    INTO @DATA(lv_hcpr_xml_def)
    WHERE hcprnm = @iv_hcprnm
    AND vers = @iv_vers.

    IF sy-subrc <> 0.
      MESSAGE 'No valid,inactive or supported CompositeProvider' TYPE 'I'.
      EXIT.
    ENDIF.

    CALL FUNCTION 'SMUM_XML_PARSE'
      EXPORTING
        xml_input = lv_hcpr_xml_def
      TABLES
        xml_table = lt_xml_info
        return    = lt_return.

    LOOP AT lt_xml_info REFERENCE INTO DATA(lr_xml_info).
      IF lr_xml_info->cname = 'entity'.
        DATA(lv_cvalue) = lr_xml_info->cvalue.
        SEARCH lv_cvalue FOR 'composite'.
        lv_offset = sy-fdpos.
        lv_offset = lv_offset - 1.
        TRY.
            ls_output-infoprovider = lr_xml_info->cvalue(lv_offset). "CompositeProvider
          CATCH cx_sy_range_out_of_bounds.
            ls_output-infoprovider = lr_xml_info->cvalue.
        ENDTRY.
      ELSEIF
       lr_xml_info->cname = 'targetName'.
        ls_output-target = lr_xml_info->cvalue.
      ELSEIF
        lr_xml_info->cname = 'sourceName'.
        ls_output-source = lr_xml_info->cvalue.
        APPEND ls_output TO lt_output.
      ENDIF.
    ENDLOOP.

    TRY.
        cl_salv_table=>factory(
        IMPORTING
        r_salv_table = DATA(lobj_alv)
        CHANGING
        t_table = lt_output ).

        DATA(lobj_columns) = lobj_alv->get_columns( ).
        lobj_columns->set_optimize( ).

        DATA(lobj_funcs) = lobj_alv->get_functions( ).
        lobj_funcs->set_all( ).

        lobj_alv->display( ).
      CATCH cx_salv_msg INTO DATA(lobj_excep).
        MESSAGE lobj_excep TYPE 'E'.
    ENDTRY.
  ENDMETHOD.

  METHOD constructor.

    create_global_ddic( ).

  ENDMETHOD.

ENDCLASS.

PARAMETERS: pa_hcpn TYPE rsohcprnm,
            pa_vers TYPE char10.

PARAMETERS: pa_bkp RADIOBUTTON GROUP rg1,
            pa_res RADIOBUTTON GROUP rg1,
            pa_sho RADIOBUTTON GROUP rg1.

DATA(lobj_hcpr_cp) = NEW zcl_bw_hcpr_cp(  ).

IF pa_bkp = abap_true.

  lobj_hcpr_cp->create_backup( iv_hcprnm = pa_hcpn
                               iv_vers = pa_vers ).

ELSEIF pa_res = abap_true.

  lobj_hcpr_cp->restore_backup(
    EXPORTING
      iv_hcprnm = pa_hcpn
      iv_vers   = pa_vers
  ).

ELSEIF pa_sho = abap_true.

  lobj_hcpr_cp->show_mapping( iv_hcprnm = pa_hcpn
                              iv_vers   = pa_vers ).

ENDIF.

****************************************************
INTERFACE lif_abapmerge_marker.
* abapmerge 0.14.7 - 2022-07-04T15:39:18.845Z
ENDINTERFACE.
****************************************************