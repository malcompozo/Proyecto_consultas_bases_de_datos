

--***********************************************************

DROP TABLE anomalias_irreparables CASCADE CONSTRAINTS;

DROP TABLE anomalias_reparables CASCADE CONSTRAINTS;

DROP TABLE ant_admin_vivienda CASCADE CONSTRAINTS;

DROP TABLE ant_constructivos_vivienda CASCADE CONSTRAINTS;

DROP TABLE caract_vivienda CASCADE CONSTRAINTS;

DROP TABLE cargas_familiares CASCADE CONSTRAINTS;

DROP TABLE comuna CASCADE CONSTRAINTS;

DROP TABLE conservacion CASCADE CONSTRAINTS;

DROP TABLE consultor CASCADE CONSTRAINTS;

DROP TABLE consultor_informe CASCADE CONSTRAINTS;

DROP TABLE conyugue CASCADE CONSTRAINTS;

DROP TABLE cta_de_ahorro CASCADE CONSTRAINTS;

DROP TABLE iden_postulante CASCADE CONSTRAINTS;

DROP TABLE informe_tec_vivienda_us CASCADE CONSTRAINTS;

DROP TABLE nacionalidad CASCADE CONSTRAINTS;

DROP TABLE postulacion_subsidio CASCADE CONSTRAINTS;

DROP TABLE programa_arquitectonico CASCADE CONSTRAINTS;

DROP TABLE propietario_vivienda CASCADE CONSTRAINTS;

DROP TABLE pueblo_originario CASCADE CONSTRAINTS;

DROP TABLE puntaje_ahorro CASCADE CONSTRAINTS;

DROP TABLE puntaje_cargas CASCADE CONSTRAINTS;

DROP TABLE puntaje_edad CASCADE CONSTRAINTS;

DROP TABLE puntaje_estado_civil CASCADE CONSTRAINTS;

DROP TABLE puntaje_pueblo CASCADE CONSTRAINTS;

DROP TABLE puntaje_titulo CASCADE CONSTRAINTS;

DROP TABLE rango_tramo CASCADE CONSTRAINTS;

DROP TABLE region CASCADE CONSTRAINTS;

DROP TABLE region_extrema CASCADE CONSTRAINTS;

DROP TABLE situacion CASCADE CONSTRAINTS;

DROP TABLE titulo CASCADE CONSTRAINTS;

DROP TABLE titulo_tramo CASCADE CONSTRAINTS;

drop sequence "SQ_ID_CARGAS_FAM";

drop sequence "SQ_ID_CONSERVACION";

drop sequence "SQ_ID_REGION";

drop sequence "SQ_NRO_FOLIO_INF";

drop sequence "SQ_NRO_FOLIO_POST";


--***********************************************************

CREATE TABLE anomalias_irreparables (
    id_irreparable   INTEGER NOT NULL,
    item             VARCHAR2(30),
    id_conservacion  INTEGER NOT NULL
);

ALTER TABLE anomalias_irreparables ADD CONSTRAINT anom_irr_pk PRIMARY KEY ( id_irreparable );

CREATE TABLE anomalias_reparables (
    id_reparable     INTEGER NOT NULL,
    item             VARCHAR2(30),
    observaciones    VARCHAR2(40),
    id_conservacion  INTEGER NOT NULL
);

ALTER TABLE anomalias_reparables ADD CONSTRAINT anom_rep_pk PRIMARY KEY ( id_reparable );

CREATE TABLE ant_admin_vivienda (
    id_antecedentes      INTEGER NOT NULL,
    permiso_edificacion  INTEGER NOT NULL,
    annio_construccion   DATE NOT NULL,
    recepcion_fiscal     INTEGER NOT NULL,
    fecha                DATE NOT NULL,
    metro_cua            INTEGER NOT NULL
);

ALTER TABLE ant_admin_vivienda ADD CONSTRAINT ant_adm_viv_pk PRIMARY KEY ( id_antecedentes );

CREATE TABLE ant_constructivos_vivienda (
    id_ante_construccion  INTEGER NOT NULL,
    tipo_vivienda         VARCHAR2(30) NOT NULL,
    cant_pisos            INTEGER NOT NULL,
    agrupacion_vivienda   VARCHAR2(30) NOT NULL,
    m2_vivienda           INTEGER NOT NULL,
    m2_terreno            INTEGER NOT NULL,
    techumbre             VARCHAR2(40) NOT NULL,
    muros                 VARCHAR2(40) NOT NULL,
    pisos_entrepisos      VARCHAR2(40) NOT NULL,
    id_antecedentes       INTEGER NOT NULL
);

COMMENT ON COLUMN ant_constructivos_vivienda.tipo_vivienda IS
    'Casa/Departamento';

COMMENT ON COLUMN ant_constructivos_vivienda.agrupacion_vivienda IS
    'Aislada/Pareada/continua/Edificacion en altura';

ALTER TABLE ant_constructivos_vivienda ADD CONSTRAINT ant_con_viv_pk PRIMARY KEY ( id_ante_construccion,
                                                                                   id_antecedentes );

CREATE TABLE caract_vivienda (
    id_caracteristicas    INTEGER NOT NULL,
    direccion             VARCHAR2(40) NOT NULL,
    num_depto             VARCHAR2(4),
    num_piso              INTEGER,
    rol_sii               INTEGER NOT NULL,
    pob_villa_condominio  VARCHAR2(40),
    id_comuna             INTEGER
);

ALTER TABLE caract_vivienda ADD CONSTRAINT car_viv_pk PRIMARY KEY ( id_caracteristicas );

CREATE TABLE cargas_familiares (
    id_carga             INTEGER NOT NULL,
    a_paterno            VARCHAR2(15) NOT NULL,
    a_materno            VARCHAR2(15) NOT NULL,
    nombre               VARCHAR2(25) NOT NULL,
    rut_carga            VARCHAR2(12) NOT NULL,
    relacion_postulante  VARCHAR2(30) NOT NULL,
    rut_postulante       INTEGER NOT NULL
);

ALTER TABLE cargas_familiares ADD CONSTRAINT car_fam_pk PRIMARY KEY ( id_carga );

CREATE TABLE comuna (
    id_comuna   INTEGER NOT NULL,
    nom_comuna  VARCHAR2(30) NOT NULL,
    id_region   INTEGER NOT NULL
);

ALTER TABLE comuna ADD CONSTRAINT com_pk PRIMARY KEY ( id_comuna );

CREATE TABLE conservacion (
    id_conservacion  INTEGER NOT NULL,
    estado           VARCHAR2(20) NOT NULL
);

COMMENT ON COLUMN conservacion.estado IS
    'bueno/regular/malo';

ALTER TABLE conservacion ADD CONSTRAINT conservacion_pk PRIMARY KEY ( id_conservacion );

CREATE TABLE consultor (
    run_consultor       INTEGER NOT NULL,
    dv_rut_consultor    VARCHAR2(1) NOT NULL,
    nombre              VARCHAR2(30) NOT NULL,
    telefono            INTEGER NOT NULL,
    correo_electronico  VARCHAR2(40),
    rol                 VARCHAR2(30) NOT NULL,
    categoria           VARCHAR2(30) NOT NULL,
    resolucion          VARCHAR2(30) NOT NULL,
    fecha_resolucion    DATE NOT NULL
);

ALTER TABLE consultor ADD CONSTRAINT con_pk PRIMARY KEY ( run_consultor );

CREATE TABLE consultor_informe (
    nro_folio_informe  INTEGER NOT NULL,
    rut_postulante     INTEGER NOT NULL,
    id_nacionalidad    INTEGER NOT NULL,
    run_consultor      INTEGER NOT NULL
);

ALTER TABLE consultor_informe
    ADD CONSTRAINT con_inf_pk PRIMARY KEY ( nro_folio_informe,
                                            rut_postulante,
                                            id_nacionalidad,
                                            run_consultor );

CREATE TABLE conyugue (
    id_coyugue        INTEGER NOT NULL,
    rut_conyugue      INTEGER NOT NULL,
    dv_conyugue       VARCHAR2(1) NOT NULL,
    fecha_nacimiento  DATE NOT NULL,
    nombres           VARCHAR2(20) NOT NULL,
    a__paterno        VARCHAR2(20) NOT NULL,
    a_materno         VARCHAR2(20) NOT NULL,
    rut_postulante    INTEGER NOT NULL
);

CREATE UNIQUE INDEX conyugue__idx ON
    conyugue (
        rut_postulante
    ASC );

ALTER TABLE conyugue ADD CONSTRAINT conyugue_pk PRIMARY KEY ( id_coyugue );

CREATE TABLE cta_de_ahorro (
    num_cuenta          INTEGER NOT NULL,
    fecha_apertura      DATE NOT NULL,
    monto_ahorrado      INTEGER NOT NULL,
    tipo_cuenta         VARCHAR2(35) NOT NULL,
    entidad_crediticia  VARCHAR2(35) NOT NULL,
    rut_postulante      INTEGER NOT NULL
);

ALTER TABLE cta_de_ahorro ADD CONSTRAINT cta_de_aho_pk PRIMARY KEY ( num_cuenta );

CREATE TABLE iden_postulante (
    rut_postulante     INTEGER NOT NULL,
    dv_rut_postulante  VARCHAR2(1) NOT NULL,
    fecha_nac          DATE NOT NULL,
    p_nombre           VARCHAR2(15) NOT NULL,
    s_nombre           VARCHAR2(15),
    a_paterno          VARCHAR2(15) NOT NULL,
    a_materno          VARCHAR2(15) NOT NULL,
    direccion          VARCHAR2(40) NOT NULL,
    estado_civil       VARCHAR2(25) NOT NULL,
    id_comuna          INTEGER NOT NULL,
    tel_trabajo        INTEGER,
    tel_domicilio      INTEGER,
    celular            INTEGER NOT NULL,
    correo             VARCHAR2(40),
    id_nacionalidad    INTEGER NOT NULL,
    id_pueblo_origin   INTEGER,
    id_acredi          INTEGER,
    sueldo             NUMBER(7) NOT NULL
);

ALTER TABLE iden_postulante ADD CONSTRAINT ide_pos_pk PRIMARY KEY ( rut_postulante );

CREATE TABLE informe_tec_vivienda_us (
    nro_folio_informe    INTEGER NOT NULL,
    rut_postulante       INTEGER NOT NULL,
    valor_vivienda       NUMBER(9),
    id_nacionalidad      INTEGER NOT NULL,
    id_caracteristicas   INTEGER NOT NULL,
    id_antecedentes      INTEGER NOT NULL,
    fecha_inspeccion     DATE NOT NULL,
    annio_obtencion_sub  DATE NOT NULL,
    rut_pro              VARCHAR2(12) NOT NULL,
    id_conservacion      INTEGER NOT NULL
    
);

ALTER TABLE informe_tec_vivienda_us
    ADD CONSTRAINT inf_tec_viv_us_pk PRIMARY KEY ( nro_folio_informe,
                                                   rut_postulante,
                                                   id_nacionalidad );

CREATE TABLE nacionalidad (
    id_nacionalidad    INTEGER NOT NULL,
    nom_nacionalidad   VARCHAR2(20) NOT NULL,
    cer_permanencia    VARCHAR2(1),
    fecha_certificado  DATE
);

COMMENT ON COLUMN nacionalidad.cer_permanencia IS
    '"S" o "N"';

ALTER TABLE nacionalidad ADD CONSTRAINT nacionalidad_pk PRIMARY KEY ( id_nacionalidad );

CREATE TABLE postulacion_subsidio (
    nro_folio_post   INTEGER NOT NULL,
    fecha_recepcion  DATE NOT NULL,
    aval_fiscal      INTEGER NOT NULL,
    id_titulo        INTEGER NOT NULL,
    rut_postulante   INTEGER NOT NULL
);

ALTER TABLE postulacion_subsidio ADD CONSTRAINT pos_sub_pk PRIMARY KEY ( nro_folio_post,
                                                                         rut_postulante );

CREATE TABLE programa_arquitectonico (
    id_programa           INTEGER NOT NULL,
    item                  VARCHAR2(30) NOT NULL,
    id_ante_construccion  INTEGER NOT NULL,
    id_antecedentes       INTEGER NOT NULL
);

ALTER TABLE programa_arquitectonico ADD CONSTRAINT pro_arq_pk PRIMARY KEY ( id_programa );

CREATE TABLE propietario_vivienda (
    rut_pro             VARCHAR2(12) NOT NULL,
    dv_rut_pro          VARCHAR2(1) NOT NULL,
    nombre_prop         VARCHAR2(40) NOT NULL,
    telefono            INTEGER,
    correo_electronico  VARCHAR2(50)
);

ALTER TABLE propietario_vivienda ADD CONSTRAINT pro_viv_pk PRIMARY KEY ( rut_pro );

CREATE TABLE pueblo_originario (
    id_pueblo_origin     INTEGER NOT NULL,
    indigena_originario  VARCHAR2(30) NOT NULL,
    acreditacion         VARCHAR2(1) NOT NULL,
    fecha_documento      DATE NOT NULL
);

COMMENT ON COLUMN pueblo_originario.acreditacion IS
    '"S" o "N"';

ALTER TABLE pueblo_originario ADD CONSTRAINT pue_ori_pk PRIMARY KEY ( id_pueblo_origin );

CREATE TABLE puntaje_ahorro (
    item       VARCHAR2(20) NOT NULL,
    monto_min  INTEGER NOT NULL,
    monto_max  INTEGER NOT NULL,
    puntaje    INTEGER NOT NULL
);

CREATE TABLE puntaje_cargas (
    item       VARCHAR2(20) NOT NULL,
    rango_min  INTEGER NOT NULL,
    rango_max  INTEGER NOT NULL,
    puntaje    INTEGER NOT NULL
);

CREATE TABLE puntaje_edad (
    item       VARCHAR2(20) NOT NULL,
    rango_min  INTEGER NOT NULL,
    rango_max  INTEGER NOT NULL,
    puntaje    INTEGER NOT NULL
);

CREATE TABLE puntaje_estado_civil (
    item         VARCHAR2(20) NOT NULL,
    descripcion  VARCHAR2(30) NOT NULL,
    puntaje      INTEGER NOT NULL
);

CREATE TABLE puntaje_pueblo (
    item         VARCHAR2(40) NOT NULL,
    descripcion  VARCHAR2(30) NOT NULL,
    puntaje      INTEGER NOT NULL
);

CREATE TABLE puntaje_titulo (
    item        VARCHAR2(20) NOT NULL,
    descrpcion  VARCHAR2(30) NOT NULL,
    puntaje     INTEGER NOT NULL
);

CREATE TABLE rango_tramo (
    op_subsidio         VARCHAR2(30) NOT NULL,
    valor_max_vivienda  INTEGER NOT NULL,
    monto_max           INTEGER NOT NULL,
    monto_min           INTEGER NOT NULL,
    ahorro_minimo       INTEGER NOT NULL
);

ALTER TABLE rango_tramo ADD CONSTRAINT rango_tramo_pk PRIMARY KEY ( op_subsidio );

CREATE TABLE region (
    id_region   INTEGER NOT NULL,
    nom_region  VARCHAR2(20) NOT NULL,
    cod_postal  INTEGER NOT NULL
);

ALTER TABLE region ADD CONSTRAINT reg_pk PRIMARY KEY ( id_region );

CREATE TABLE region_extrema (
    id_region   INTEGER NOT NULL,
    region      VARCHAR2(20) NOT NULL,
    porc_extra  INTEGER NOT NULL
);

ALTER TABLE region_extrema ADD CONSTRAINT region_extrema_pk PRIMARY KEY ( id_region );

CREATE TABLE situacion (
    id_situacion INTEGER NOT NULL,
    situacion    VARCHAR2(40) NOT NULL,
    descripcion  VARCHAR2(300) NOT NULL
);

CREATE TABLE titulo (
    id_acredi        INTEGER NOT NULL,
    nom_titulo       VARCHAR2(35),
    nom_institucion  VARCHAR2(35),
    tipo_titulo      VARCHAR2(20)
);

ALTER TABLE titulo ADD CONSTRAINT titulo_pk PRIMARY KEY ( id_acredi );

CREATE TABLE titulo_tramo (
    id_titulo  INTEGER NOT NULL,
    op_titulo  VARCHAR2(20) NOT NULL,
    id_comuna  INTEGER NOT NULL
);

ALTER TABLE titulo_tramo ADD CONSTRAINT tit_tra_pk PRIMARY KEY ( id_titulo );

ALTER TABLE anomalias_irreparables
    ADD CONSTRAINT ano_irr_con_fk FOREIGN KEY ( id_conservacion )
        REFERENCES conservacion ( id_conservacion );

ALTER TABLE anomalias_reparables
    ADD CONSTRAINT anom_rep_con_fk FOREIGN KEY ( id_conservacion )
        REFERENCES conservacion ( id_conservacion );

ALTER TABLE ant_constructivos_vivienda
    ADD CONSTRAINT ant_con_viv_ant_adm_viv_fk FOREIGN KEY ( id_antecedentes )
        REFERENCES ant_admin_vivienda ( id_antecedentes );

ALTER TABLE cargas_familiares
    ADD CONSTRAINT car_fam_ide_pos_fk FOREIGN KEY ( rut_postulante )
        REFERENCES iden_postulante ( rut_postulante );

ALTER TABLE caract_vivienda
    ADD CONSTRAINT car_viv_com_fk FOREIGN KEY ( id_comuna )
        REFERENCES comuna ( id_comuna );

ALTER TABLE comuna
    ADD CONSTRAINT com_reg_fk FOREIGN KEY ( id_region )
        REFERENCES region ( id_region );

ALTER TABLE conyugue
    ADD CONSTRAINT con_ide_pos_fk FOREIGN KEY ( rut_postulante )
        REFERENCES iden_postulante ( rut_postulante );

ALTER TABLE consultor_informe
    ADD CONSTRAINT con_inf_con_fk FOREIGN KEY ( run_consultor )
        REFERENCES consultor ( run_consultor );

ALTER TABLE consultor_informe
    ADD CONSTRAINT con_inf_inf_tec_viv_us_fk FOREIGN KEY ( nro_folio_informe,
                                                           rut_postulante,
                                                           id_nacionalidad )
        REFERENCES informe_tec_vivienda_us ( nro_folio_informe,
                                             rut_postulante,
                                             id_nacionalidad );

ALTER TABLE cta_de_ahorro
    ADD CONSTRAINT cta_de_aho_ide_pos_fk FOREIGN KEY ( rut_postulante )
        REFERENCES iden_postulante ( rut_postulante );

ALTER TABLE iden_postulante
    ADD CONSTRAINT ide_pos_com_fk FOREIGN KEY ( id_comuna )
        REFERENCES comuna ( id_comuna );

ALTER TABLE iden_postulante
    ADD CONSTRAINT ide_pos_nac_fk FOREIGN KEY ( id_nacionalidad )
        REFERENCES nacionalidad ( id_nacionalidad );

ALTER TABLE iden_postulante
    ADD CONSTRAINT ide_pos_pue_ori_fk FOREIGN KEY ( id_pueblo_origin )
        REFERENCES pueblo_originario ( id_pueblo_origin );

ALTER TABLE iden_postulante
    ADD CONSTRAINT ide_pos_tit_fk FOREIGN KEY ( id_acredi )
        REFERENCES titulo ( id_acredi );

ALTER TABLE informe_tec_vivienda_us
    ADD CONSTRAINT inf_tec_viv_us_ant_adm_viv_fk FOREIGN KEY ( id_antecedentes )
        REFERENCES ant_admin_vivienda ( id_antecedentes );

ALTER TABLE informe_tec_vivienda_us
    ADD CONSTRAINT inf_tec_viv_us_car_viv_fk FOREIGN KEY ( id_caracteristicas )
        REFERENCES caract_vivienda ( id_caracteristicas );

ALTER TABLE informe_tec_vivienda_us
    ADD CONSTRAINT inf_tec_viv_us_con_fk FOREIGN KEY ( id_conservacion )
        REFERENCES conservacion ( id_conservacion );

ALTER TABLE informe_tec_vivienda_us
    ADD CONSTRAINT inf_tec_viv_us_ide_pose_fk FOREIGN KEY ( rut_postulante )
        REFERENCES iden_postulante ( rut_postulante );

ALTER TABLE informe_tec_vivienda_us
    ADD CONSTRAINT inf_tec_viv_us_pro_viv_fk FOREIGN KEY ( rut_pro )
        REFERENCES propietario_vivienda ( rut_pro );

ALTER TABLE postulacion_subsidio
    ADD CONSTRAINT pos_sub_ide_pos_fk FOREIGN KEY ( rut_postulante )
        REFERENCES iden_postulante ( rut_postulante );

ALTER TABLE postulacion_subsidio
    ADD CONSTRAINT pos_sub_tit_tra_fk FOREIGN KEY ( id_titulo )
        REFERENCES titulo_tramo ( id_titulo );

ALTER TABLE programa_arquitectonico
    ADD CONSTRAINT pro_arq_ant_con_viv_fk FOREIGN KEY ( id_ante_construccion,
                                                        id_antecedentes )
        REFERENCES ant_constructivos_vivienda ( id_ante_construccion,
                                                id_antecedentes );

ALTER TABLE titulo_tramo
    ADD CONSTRAINT titulo_tramo_comuna_fk FOREIGN KEY ( id_comuna )
        REFERENCES comuna ( id_comuna );                                







