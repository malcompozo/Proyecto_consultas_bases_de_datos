-------------------------------------- 3.1 RESUMEN TOTAL --------------------------------------

SELECT 
    NOM_REGION REGION,
    SUM((SELECT COUNT(*)
    FROM TITULO_TRAMO WHERE OP_TITULO='TITULO I TRAMO 1' AND ID_COMUNA = CO.ID_COMUNA))"TITULO I TRAMO 1",
    SUM((SELECT COUNT(*)
    FROM TITULO_TRAMO WHERE OP_TITULO='TITULO I TRAMO 2' AND ID_COMUNA = CO.ID_COMUNA))"TITULO I TRAMO 2",
    SUM((SELECT COUNT(*)
    FROM TITULO_TRAMO WHERE OP_TITULO='TITULO II' AND ID_COMUNA = CO.ID_COMUNA))"TITULO II",
    SUM((SELECT COUNT(*)
    FROM TITULO_TRAMO WHERE ID_COMUNA = CO.ID_COMUNA)) "TITULO POSTULANTES"
FROM REGION REG
JOIN COMUNA CO 
    ON REG.ID_REGION = CO.ID_REGION
GROUP BY NOM_REGION;
    
    
    
-------------------------------------- 3.2 DETALLE POSTULANTES ------------------------------------------

SELECT 
    PS.NRO_FOLIO_POST "NRO FOLIO",
    SUBSTR(IP.RUT_POSTULANTE,1,2)||((SUBSTR(PS.NRO_FOLIO_POST,-1)-1)*3+10)||SUBSTR(IP.RUT_POSTULANTE,-6,6)||SUBSTR(TO_CHAR(IP.FECHA_NAC,'Month'),1,2)||'-'
    ||IP.DV_RUT_POSTULANTE||SUBSTR(PS.NRO_FOLIO_POST,-1) RUT,
    INITCAP(P_NOMBRE||' '||S_NOMBRE||' '||A_PATERNO||' '||A_MATERNO) "NOMBRE POSTULANTE",
    PS.FECHA_RECEPCION "FECHA POSTULACION",
    INITCAP(IP.ESTADO_CIVIL) "EST.CIVIL",
    INITCAP(IP.DIRECCION||', '||CO.NOM_COMUNA) DIRECCION,
    TTRA.OP_TITULO "OPCION DE POSTULACION",
    CASE
        WHEN SUELDO > 1200000 AND SUELDO < 2000000 THEN 'Si cumple, ser� considerado en el proceso'
        ELSE 'No cumple, no ser� considerado en el proceso'
    END "CUMPLE CON REQUISITOS"
FROM IDEN_POSTULANTE IP
JOIN POSTULACION_SUBSIDIO PS
    ON IP.RUT_POSTULANTE = PS.RUT_POSTULANTE
JOIN COMUNA CO 
    ON CO.ID_COMUNA = IP.ID_COMUNA
JOIN TITULO_TRAMO TTRA
    ON TTRA.ID_COMUNA = CO.ID_COMUNA
ORDER BY "NRO FOLIO";
    
    
    
    
-------------------------------------- 3.3 PUNTAJES OBTENIDOS --------------------------------------
SELECT 
    POST.RUT_POSTULANTE||'-'||POST.DV_RUT_POSTULANTE "RUN POSTULANTE", 
    POST.P_NOMBRE||' '||POST.S_NOMBRE||' '||POST.A_PATERNO||' '||POST.A_MATERNO "NOMBRE POSTULANTE",
    TRUNC(MONTHS_BETWEEN(SYSDATE,POST.FECHA_NAC)/12) EDAD,
    PE.PUNTAJE "PTJE EDAD",
    COUNT(CF.RUT_CARGA) "CARGAS FAM",
    PC.PUNTAJE "PTJE CARGA",
    POST.ESTADO_CIVIL "ESTADO CIVIL",
    PEC.PUNTAJE "PTJE EST. CIVIL.",
    NVL(POR.INDIGENA_ORIGINARIO,'No') "PUEBLO IND. ORIG.",
    NVL(PP.PUNTAJE,0) "PTJE. PUEBLO IND. ORIG.",
    TO_CHAR(CDA.MONTO_AHORRADO,'L999G999G999') "MONTO AHORRADO",
    PA.PUNTAJE "PTJE. MONTO AHORRO",
    T.NOM_TITULO "TITULO",
    PT.PUNTAJE "PTJE. TITULO",
    CASE
        WHEN (CV.ID_COMUNA = 600 AND REG.ID_REGION = 14) AND rex.region = 'AYS�N' THEN 'SI'
        WHEN CV.ID_COMUNA = 700 THEN 'SI'
        ELSE 'NO'
    END "ZONA EXTREMA",
    NVL((PE.PUNTAJE + PC.PUNTAJE + PEC.PUNTAJE + NVL(PP.PUNTAJE,0) + PA.PUNTAJE + PT.PUNTAJE)/REX.PORC_EXTRA,0) "PTJE. ZONA EXTREMA",
    (PE.PUNTAJE + PC.PUNTAJE + PEC.PUNTAJE + NVL(PP.PUNTAJE,0) + PA.PUNTAJE + PT.PUNTAJE) "PUNTAJE TOTAL"

    
FROM IDEN_POSTULANTE POST

JOIN PUNTAJE_EDAD PE 
    ON TRUNC (MONTHS_BETWEEN(SYSDATE,POST.FECHA_NAC)/12) BETWEEN PE.RANGO_MIN AND PE.RANGO_MAX
    
LEFT JOIN CARGAS_FAMILIARES CF 
    ON POST.RUT_POSTULANTE = CF.RUT_POSTULANTE      
JOIN PUNTAJE_CARGAS PC 
    ON (SELECT COUNT(RUT_CARGA) FROM CARGAS_FAMILIARES WHERE POST.RUT_POSTULANTE = CF.RUT_POSTULANTE) BETWEEN PC.RANGO_MIN AND PC.RANGO_MAX

JOIN PUNTAJE_ESTADO_CIVIL PEC
    ON POST.ESTADO_CIVIL IN PEC.DESCRIPCION
    
LEFT JOIN PUEBLO_ORIGINARIO POR
    ON POST.ID_PUEBLO_ORIGIN = POR.ID_PUEBLO_ORIGIN
    
LEFT JOIN PUNTAJE_PUEBLO PP
    ON POR.INDIGENA_ORIGINARIO = PP.DESCRIPCION

JOIN CTA_DE_AHORRO CDA
    ON POST.RUT_POSTULANTE = CDA.RUT_POSTULANTE
JOIN PUNTAJE_AHORRO PA
    ON MONTO_AHORRADO BETWEEN MONTO_MIN AND MONTO_MAX
    
JOIN TITULO T
    ON POST.ID_ACREDI = T.ID_ACREDI
LEFT JOIN PUNTAJE_TITULO PT
    ON T.TIPO_TITULO = PT.DESCRPCION

LEFT JOIN COMUNA CO
    ON CO.ID_COMUNA = POST.ID_COMUNA
    
LEFT JOIN CARACT_VIVIENDA CV
    ON CO.ID_COMUNA = CV.ID_COMUNA

JOIN REGION REG
    ON REG.ID_REGION = CO.ID_REGION
    
LEFT JOIN REGION_EXTREMA REX
    ON REG.NOM_REGION IN REX.REGION

GROUP BY POST.RUT_POSTULANTE,POST.DV_RUT_POSTULANTE,POST.P_NOMBRE,POST.S_NOMBRE,
         POST.A_PATERNO,POST.A_MATERNO,POST.FECHA_NAC,PE.PUNTAJE,PC.PUNTAJE,
         ESTADO_CIVIL,PEC.PUNTAJE,NVL(POR.INDIGENA_ORIGINARIO,'No'),NVL(PP.PUNTAJE,0),
         CDA.MONTO_AHORRADO,PA.PUNTAJE,T.NOM_TITULO,PT.PUNTAJE,
         CASE
        WHEN (CV.ID_COMUNA = 600 AND REG.ID_REGION = 14) AND rex.region = 'AYS�N' THEN 'SI'
        WHEN CV.ID_COMUNA = 700 THEN 'SI'
        ELSE 'NO'
        END,(PE.PUNTAJE + PC.PUNTAJE + PEC.PUNTAJE + NVL(PP.PUNTAJE,0) + PA.PUNTAJE + PT.PUNTAJE)/REX.PORC_EXTRA;
   
   
   
   
-------------------------------------- 3.4 POSTULANTES FAVORECIDOS --------------------------------------
--CREATE VIEW POSTULANTES_FAVORECIDOS AS
SELECT 
    POST.RUT_POSTULANTE||'-'||POST.DV_RUT_POSTULANTE "RUN POSTULANTE", 
    POST.P_NOMBRE||' '||POST.S_NOMBRE||' '||POST.A_PATERNO||' '||POST.A_MATERNO "NOMBRE POSTULANTE",
    TRUNC(MONTHS_BETWEEN(SYSDATE,POST.FECHA_NAC)/12) EDAD,
    PE.PUNTAJE "PTJE EDAD",
    COUNT(CF.RUT_CARGA) "CARGAS FAM",
    PC.PUNTAJE "PTJE CARGA",
    POST.ESTADO_CIVIL "ESTADO CIVIL",
    PEC.PUNTAJE "PTJE EST. CIVIL.",
    NVL(POR.INDIGENA_ORIGINARIO,'No') "PUEBLO IND. ORIG.",
    NVL(PP.PUNTAJE,0) "PTJE. PUEBLO IND. ORIG.",
    TO_CHAR(CDA.MONTO_AHORRADO,'L999G999G999') "MONTO AHORRADO",
    PA.PUNTAJE "PTJE. MONTO AHORRO",
    T.NOM_TITULO "TITULO",
    PT.PUNTAJE "PTJE. TITULO",
    CASE
        WHEN (CV.ID_COMUNA = 600 AND REG.ID_REGION = 14) AND rex.region = 'AYS�N' THEN 'SI'
        WHEN CV.ID_COMUNA = 700 THEN 'SI'
        ELSE 'NO'
    END "ZONA EXTREMA",
    NVL((PE.PUNTAJE + PC.PUNTAJE + PEC.PUNTAJE + NVL(PP.PUNTAJE,0) + PA.PUNTAJE + PT.PUNTAJE)/REX.PORC_EXTRA,0) "PTJE. ZONA EXTREMA",
    (PE.PUNTAJE + PC.PUNTAJE + PEC.PUNTAJE + NVL(PP.PUNTAJE,0) + PA.PUNTAJE + PT.PUNTAJE + NVL((PE.PUNTAJE + PC.PUNTAJE + PEC.PUNTAJE + NVL(PP.PUNTAJE,0) + PA.PUNTAJE + PT.PUNTAJE)/REX.PORC_EXTRA,0)) "PUNTAJE TOTAL",
    ANT.TIPO_VIVIENDA "TIPO VIVIENDA",
    TO_CHAR(ITV.VALOR_VIVIENDA * 29057,'L999G999G999') "VALOR VIVIENDA",
    TO_CHAR(RT.MONTO_MAX*29057,'L999G999G999') "MONTO SUBSIDIO"

FROM IDEN_POSTULANTE POST

------------------------------------------------
JOIN PUNTAJE_EDAD PE 
    ON TRUNC (MONTHS_BETWEEN(SYSDATE,POST.FECHA_NAC)/12) BETWEEN PE.RANGO_MIN AND PE.RANGO_MAX
    
LEFT JOIN CARGAS_FAMILIARES CF 
    ON POST.RUT_POSTULANTE = CF.RUT_POSTULANTE      
JOIN PUNTAJE_CARGAS PC 
    ON (SELECT COUNT(RUT_CARGA) FROM CARGAS_FAMILIARES WHERE POST.RUT_POSTULANTE = CF.RUT_POSTULANTE) BETWEEN PC.RANGO_MIN AND PC.RANGO_MAX

JOIN PUNTAJE_ESTADO_CIVIL PEC
    ON POST.ESTADO_CIVIL IN PEC.DESCRIPCION
    
LEFT JOIN PUEBLO_ORIGINARIO POR
    ON POST.ID_PUEBLO_ORIGIN = POR.ID_PUEBLO_ORIGIN
    
LEFT JOIN PUNTAJE_PUEBLO PP
    ON POR.INDIGENA_ORIGINARIO = PP.DESCRIPCION

JOIN CTA_DE_AHORRO CDA
    ON POST.RUT_POSTULANTE = CDA.RUT_POSTULANTE
JOIN PUNTAJE_AHORRO PA
    ON MONTO_AHORRADO BETWEEN MONTO_MIN AND MONTO_MAX
    
JOIN TITULO T
    ON POST.ID_ACREDI = T.ID_ACREDI
LEFT JOIN PUNTAJE_TITULO PT
    ON T.TIPO_TITULO = PT.DESCRPCION

LEFT JOIN COMUNA CO
    ON CO.ID_COMUNA = POST.ID_COMUNA
    
LEFT JOIN CARACT_VIVIENDA CV
    ON CO.ID_COMUNA = CV.ID_COMUNA

JOIN REGION REG
    ON REG.ID_REGION = CO.ID_REGION
    
LEFT JOIN REGION_EXTREMA REX
    ON REG.NOM_REGION IN REX.REGION

JOIN INFORME_TEC_VIVIENDA_US ITV
    ON ITV.RUT_POSTULANTE = POST.RUT_POSTULANTE
    
JOIN ANT_CONSTRUCTIVOS_VIVIENDA ANT
    ON ITV.ID_ANTECEDENTES = ANT.ID_ANTECEDENTES

JOIN POSTULACION_SUBSIDIO PSUB
    ON PSUB.RUT_POSTULANTE = POST.RUT_POSTULANTE   

JOIN TITULO_TRAMO TT
    ON TT.ID_TITULO = PSUB.ID_TITULO
    
JOIN RANGO_TRAMO RT
    ON TT.OP_TITULO IN RT.OP_SUBSIDIO
------------------------------------------------------------ 
WHERE (PE.PUNTAJE + PC.PUNTAJE + PEC.PUNTAJE + NVL(PP.PUNTAJE,0) + PA.PUNTAJE + PT.PUNTAJE + 
       NVL((PE.PUNTAJE + PC.PUNTAJE + PEC.PUNTAJE + NVL(PP.PUNTAJE,0) + PA.PUNTAJE + PT.PUNTAJE)/REX.PORC_EXTRA,0)) >
        
        (SELECT 
        TRUNC(AVG((PE.PUNTAJE + PC.PUNTAJE + PEC.PUNTAJE + NVL(PP.PUNTAJE,0) + PA.PUNTAJE + PT.PUNTAJE + NVL((PE.PUNTAJE + PC.PUNTAJE + PEC.PUNTAJE + NVL(PP.PUNTAJE,0) + PA.PUNTAJE + PT.PUNTAJE)/REX.PORC_EXTRA,0)))) "PUNTAJE TOTAL"  
        FROM IDEN_POSTULANTE POST
        JOIN PUNTAJE_EDAD PE 
            ON TRUNC (MONTHS_BETWEEN(SYSDATE,POST.FECHA_NAC)/12) BETWEEN PE.RANGO_MIN AND PE.RANGO_MAX    
        LEFT JOIN CARGAS_FAMILIARES CF 
            ON POST.RUT_POSTULANTE = CF.RUT_POSTULANTE      
        JOIN PUNTAJE_CARGAS PC 
            ON (SELECT COUNT(RUT_CARGA) FROM CARGAS_FAMILIARES WHERE POST.RUT_POSTULANTE = CF.RUT_POSTULANTE) BETWEEN PC.RANGO_MIN AND PC.RANGO_MAX
        JOIN PUNTAJE_ESTADO_CIVIL PEC
            ON POST.ESTADO_CIVIL IN PEC.DESCRIPCION    
        LEFT JOIN PUEBLO_ORIGINARIO POR
            ON POST.ID_PUEBLO_ORIGIN = POR.ID_PUEBLO_ORIGIN    
        LEFT JOIN PUNTAJE_PUEBLO PP
            ON POR.INDIGENA_ORIGINARIO = PP.DESCRIPCION
        JOIN CTA_DE_AHORRO CDA
            ON POST.RUT_POSTULANTE = CDA.RUT_POSTULANTE
        JOIN PUNTAJE_AHORRO PA
            ON CDA.MONTO_AHORRADO BETWEEN MONTO_MIN AND MONTO_MAX   
        JOIN TITULO T
            ON POST.ID_ACREDI = T.ID_ACREDI
        LEFT JOIN PUNTAJE_TITULO PT
            ON T.TIPO_TITULO = PT.DESCRPCION
        LEFT JOIN COMUNA CO
            ON CO.ID_COMUNA = POST.ID_COMUNA    
        LEFT JOIN CARACT_VIVIENDA CV
            ON CO.ID_COMUNA = CV.ID_COMUNA
        JOIN REGION REG
            ON REG.ID_REGION = CO.ID_REGION    
        LEFT JOIN REGION_EXTREMA REX
            ON REG.NOM_REGION IN REX.REGION)
------------------------------------------------------
GROUP BY POST.RUT_POSTULANTE,POST.DV_RUT_POSTULANTE,POST.P_NOMBRE,POST.S_NOMBRE,
         POST.A_PATERNO,POST.A_MATERNO,POST.FECHA_NAC,PE.PUNTAJE,PC.PUNTAJE,
         ESTADO_CIVIL,PEC.PUNTAJE,NVL(POR.INDIGENA_ORIGINARIO,'No'),NVL(PP.PUNTAJE,0),
         CDA.MONTO_AHORRADO,PA.PUNTAJE,T.NOM_TITULO,PT.PUNTAJE,
         CASE
        WHEN (CV.ID_COMUNA = 600 AND REG.ID_REGION = 14) AND rex.region = 'AYS�N' THEN 'SI'
        WHEN CV.ID_COMUNA = 700 THEN 'SI'
        ELSE 'NO'
        END,(PE.PUNTAJE + PC.PUNTAJE + PEC.PUNTAJE + NVL(PP.PUNTAJE,0) + PA.PUNTAJE + PT.PUNTAJE)/REX.PORC_EXTRA,
        ANT.TIPO_VIVIENDA,ITV.VALOR_VIVIENDA,RT.MONTO_MAX*29057
ORDER BY "RUN POSTULANTE";
        
CREATE INDEX PTJE_CARGAS ON PUNTAJE_CARGAS(PUNTAJE);
CREATE INDEX CARGAS_FAMI ON CARGAS_FAMILIARES(RUT_CARGA);


--******************** SUB-CONSULTA CREANDO UNA VISTA ****************
CREATE VIEW PROMEDIO AS
SELECT 

    TRUNC(AVG((PE.PUNTAJE + PC.PUNTAJE + PEC.PUNTAJE + NVL(PP.PUNTAJE,0) + PA.PUNTAJE + PT.PUNTAJE + NVL((PE.PUNTAJE + PC.PUNTAJE + PEC.PUNTAJE + NVL(PP.PUNTAJE,0) + PA.PUNTAJE + PT.PUNTAJE)/REX.PORC_EXTRA,0)))) "PUNTAJE TOTAL"
  
FROM IDEN_POSTULANTE POST

JOIN PUNTAJE_EDAD PE 
    ON TRUNC (MONTHS_BETWEEN(SYSDATE,POST.FECHA_NAC)/12) BETWEEN PE.RANGO_MIN AND PE.RANGO_MAX    
LEFT JOIN CARGAS_FAMILIARES CF 
    ON POST.RUT_POSTULANTE = CF.RUT_POSTULANTE      
JOIN PUNTAJE_CARGAS PC 
    ON (SELECT COUNT(RUT_CARGA) FROM CARGAS_FAMILIARES WHERE POST.RUT_POSTULANTE = CF.RUT_POSTULANTE) BETWEEN PC.RANGO_MIN AND PC.RANGO_MAX
JOIN PUNTAJE_ESTADO_CIVIL PEC
    ON POST.ESTADO_CIVIL IN PEC.DESCRIPCION    
LEFT JOIN PUEBLO_ORIGINARIO POR
    ON POST.ID_PUEBLO_ORIGIN = POR.ID_PUEBLO_ORIGIN    
LEFT JOIN PUNTAJE_PUEBLO PP
    ON POR.INDIGENA_ORIGINARIO = PP.DESCRIPCION
JOIN CTA_DE_AHORRO CDA
    ON POST.RUT_POSTULANTE = CDA.RUT_POSTULANTE
JOIN PUNTAJE_AHORRO PA
    ON CDA.MONTO_AHORRADO BETWEEN MONTO_MIN AND MONTO_MAX   
JOIN TITULO T
    ON POST.ID_ACREDI = T.ID_ACREDI
LEFT JOIN PUNTAJE_TITULO PT
    ON T.TIPO_TITULO = PT.DESCRPCION
LEFT JOIN COMUNA CO
    ON CO.ID_COMUNA = POST.ID_COMUNA    
LEFT JOIN CARACT_VIVIENDA CV
    ON CO.ID_COMUNA = CV.ID_COMUNA
JOIN REGION REG
    ON REG.ID_REGION = CO.ID_REGION    
LEFT JOIN REGION_EXTREMA REX
    ON REG.NOM_REGION IN REX.REGION;
    
    
SELECT * FROM POSTULANTES_FAVORECIDOS;




-------------------------------------- 3.5 POSTULANTES QUE NO FUERON FAVORECIDOS --------------------------------------
-- USO DE VISTA EN SUBCONSULTA --
SELECT 
    POST.RUT_POSTULANTE||'-'||POST.DV_RUT_POSTULANTE "RUN POSTULANTE", 
    INITCAP(POST.P_NOMBRE||' '||POST.S_NOMBRE||' '||POST.A_PATERNO||' '||POST.A_MATERNO) "NOMBRE POSTULANTE",
    INITCAP(POST.DIRECCION||', '||CO.NOM_COMUNA||', '||REG.NOM_REGION) DIRECCION,
    TT.OP_TITULO "OPCION DE SUBSIDIO",
    INITCAP(ACV.TIPO_VIVIENDA) "TIPO DE POSTULO",
    CDA.NUM_CUENTA " NUMERO DE CUENTA",
    CDA.ENTIDAD_CREDITICIA "INSTITUCION FINANCIERA"

FROM IDEN_POSTULANTE POST

------------------------------------------------
JOIN PUNTAJE_EDAD PE 
    ON TRUNC (MONTHS_BETWEEN(SYSDATE,POST.FECHA_NAC)/12) BETWEEN PE.RANGO_MIN AND PE.RANGO_MAX    
LEFT JOIN CARGAS_FAMILIARES CF 
    ON POST.RUT_POSTULANTE = CF.RUT_POSTULANTE      
JOIN PUNTAJE_CARGAS PC 
    ON (SELECT COUNT(RUT_CARGA) FROM CARGAS_FAMILIARES WHERE POST.RUT_POSTULANTE = CF.RUT_POSTULANTE) BETWEEN PC.RANGO_MIN AND PC.RANGO_MAX
JOIN PUNTAJE_ESTADO_CIVIL PEC
    ON POST.ESTADO_CIVIL IN PEC.DESCRIPCION   
LEFT JOIN PUEBLO_ORIGINARIO POR
    ON POST.ID_PUEBLO_ORIGIN = POR.ID_PUEBLO_ORIGIN    
LEFT JOIN PUNTAJE_PUEBLO PP
    ON POR.INDIGENA_ORIGINARIO = PP.DESCRIPCION
JOIN CTA_DE_AHORRO CDA
    ON POST.RUT_POSTULANTE = CDA.RUT_POSTULANTE
JOIN PUNTAJE_AHORRO PA
    ON MONTO_AHORRADO BETWEEN MONTO_MIN AND MONTO_MAX    
JOIN TITULO T
    ON POST.ID_ACREDI = T.ID_ACREDI
LEFT JOIN PUNTAJE_TITULO PT
    ON T.TIPO_TITULO = PT.DESCRPCION
LEFT JOIN COMUNA CO
    ON CO.ID_COMUNA = POST.ID_COMUNA    
LEFT JOIN CARACT_VIVIENDA CV
    ON CO.ID_COMUNA = CV.ID_COMUNA
JOIN REGION REG
    ON REG.ID_REGION = CO.ID_REGION    
LEFT JOIN REGION_EXTREMA REX
    ON REG.NOM_REGION IN REX.REGION
JOIN TITULO_TRAMO TT 
    ON CO.ID_COMUNA = TT.ID_COMUNA
JOIN CTA_DE_AHORRO CDA 
    ON POST.RUT_POSTULANTE = CDA.RUT_POSTULANTE
JOIN INFORME_TEC_VIVIENDA_US ITV 
    ON POST.RUT_POSTULANTE = ITV.RUT_POSTULANTE
JOIN ANT_ADMIN_VIVIENDA ADV 
    ON ITV.ID_ANTECEDENTES = ADV.ID_ANTECEDENTES
JOIN ANT_CONSTRUCTIVOS_VIVIENDA ACV 
    ON ADV.ID_ANTECEDENTES = ACV.ID_ANTECEDENTES


------------------------------------------------------------ 
WHERE (PE.PUNTAJE + PC.PUNTAJE + PEC.PUNTAJE + NVL(PP.PUNTAJE,0) + PA.PUNTAJE + PT.PUNTAJE + 
       NVL((PE.PUNTAJE + PC.PUNTAJE + PEC.PUNTAJE + NVL(PP.PUNTAJE,0) + PA.PUNTAJE + PT.PUNTAJE)/REX.PORC_EXTRA,0)) <
        
        (SELECT * FROM PROMEDIO)
------------------------------------------------------
GROUP BY POST.RUT_POSTULANTE,POST.DV_RUT_POSTULANTE,POST.P_NOMBRE,POST.S_NOMBRE,
         POST.A_PATERNO,POST.A_MATERNO,INITCAP(POST.DIRECCION||', '||CO.NOM_COMUNA||', '||REG.NOM_REGION),
         TT.OP_TITULO,ACV.TIPO_VIVIENDA, CDA.NUM_CUENTA, CDA.ENTIDAD_CREDITICIA;


---------------------------------------- SEGUNDO TIPO OPERADORE SET ---------------------------------------       
------------------------------------------- PARA CREAR VIEW 3.5 -------------------------------------------
CREATE VIEW POSTULANTE_35 AS
SELECT 
    POST.RUT_POSTULANTE||'-'||POST.DV_RUT_POSTULANTE "RUN POSTULANTE", 
    POST.P_NOMBRE||' '||POST.S_NOMBRE||' '||POST.A_PATERNO||' '||POST.A_MATERNO "NOMBRE POSTULANTE",
    POST.DIRECCION||','||CO.NOM_COMUNA||','||REG.NOM_REGION DIRECCION,
    TT.OP_TITULO "OPCION DE SUBSIDIO",
    ACV.TIPO_VIVIENDA "TIPO DE POSTULO",
    CDA.NUM_CUENTA " NUMERO DE CUENTA",
    CDA.ENTIDAD_CREDITICIA "INSTITUCION FINANCIERA",
    (PE.PUNTAJE + PC.PUNTAJE + PEC.PUNTAJE + NVL(PP.PUNTAJE,0) + PA.PUNTAJE + PT.PUNTAJE) "PUNTAJE TOTAL"

    
FROM IDEN_POSTULANTE POST

JOIN PUNTAJE_EDAD PE 
    ON TRUNC (MONTHS_BETWEEN(SYSDATE,POST.FECHA_NAC)/12) BETWEEN PE.RANGO_MIN AND PE.RANGO_MAX    
LEFT JOIN CARGAS_FAMILIARES CF 
    ON POST.RUT_POSTULANTE = CF.RUT_POSTULANTE      
JOIN PUNTAJE_CARGAS PC 
    ON (SELECT COUNT(RUT_CARGA) FROM CARGAS_FAMILIARES WHERE POST.RUT_POSTULANTE = CF.RUT_POSTULANTE) BETWEEN PC.RANGO_MIN AND PC.RANGO_MAX
JOIN PUNTAJE_ESTADO_CIVIL PEC
    ON POST.ESTADO_CIVIL IN PEC.DESCRIPCION    
LEFT JOIN PUEBLO_ORIGINARIO POR
    ON POST.ID_PUEBLO_ORIGIN = POR.ID_PUEBLO_ORIGIN    
LEFT JOIN PUNTAJE_PUEBLO PP
    ON POR.INDIGENA_ORIGINARIO = PP.DESCRIPCION
JOIN CTA_DE_AHORRO CDA
    ON POST.RUT_POSTULANTE = CDA.RUT_POSTULANTE
JOIN PUNTAJE_AHORRO PA
    ON MONTO_AHORRADO BETWEEN MONTO_MIN AND MONTO_MAX    
JOIN TITULO T
    ON POST.ID_ACREDI = T.ID_ACREDI
LEFT JOIN PUNTAJE_TITULO PT
    ON T.TIPO_TITULO = PT.DESCRPCION
LEFT JOIN COMUNA CO
    ON CO.ID_COMUNA = POST.ID_COMUNA    
LEFT JOIN CARACT_VIVIENDA CV
    ON CO.ID_COMUNA = CV.ID_COMUNA
LEFT JOIN REGION REG
    ON REG.ID_REGION = CO.ID_REGION
LEFT JOIN REGION_EXTREMA REGX
    ON REG.NOM_REGION IN REGX.REGION
JOIN TITULO_TRAMO TT ON CO.ID_COMUNA = TT.ID_COMUNA
JOIN CTA_DE_AHORRO CDA ON POST.RUT_POSTULANTE = CDA.RUT_POSTULANTE
JOIN INFORME_TEC_VIVIENDA_US ITV ON POST.RUT_POSTULANTE = ITV.RUT_POSTULANTE
JOIN ANT_ADMIN_VIVIENDA ADV ON ITV.ID_ANTECEDENTES = ADV.ID_ANTECEDENTES
JOIN ANT_CONSTRUCTIVOS_VIVIENDA ACV ON ADV.ID_ANTECEDENTES = ACV.ID_ANTECEDENTES

GROUP BY POST.RUT_POSTULANTE||'-'||POST.DV_RUT_POSTULANTE, 
    POST.P_NOMBRE||' '||POST.S_NOMBRE||' '||POST.A_PATERNO||' '||POST.A_MATERNO,
    POST.DIRECCION||','||CO.NOM_COMUNA||','||REG.NOM_REGION,
    TT.OP_TITULO,
    ACV.TIPO_VIVIENDA,
    CDA.NUM_CUENTA,
    CDA.ENTIDAD_CREDITICIA,
    TT.OP_TITULO,
    ACV.TIPO_VIVIENDA ,
    CDA.NUM_CUENTA,
    CDA.ENTIDAD_CREDITICIA ,
    (PE.PUNTAJE + PC.PUNTAJE + PEC.PUNTAJE + NVL(PP.PUNTAJE,0) + PA.PUNTAJE + PT.PUNTAJE),REG.NOM_REGION, POST.A_PATERNO
ORDER BY REG.NOM_REGION, POST.A_PATERNO;


------------------------------------------ OPERADOR SET 3.5 ------------------------------------------
SELECT 
    "RUN POSTULANTE", 
    "NOMBRE POSTULANTE",
    DIRECCION, 
    "OPCION DE SUBSIDIO", 
    "TIPO DE POSTULO",  
    " NUMERO DE CUENTA", 
    "INSTITUCION FINANCIERA"
FROM POSTULANTE_35

MINUS

SELECT 
    "RUN POSTULANTE", 
    "NOMBRE POSTULANTE",
    DIRECCION, 
    "OPCION DE SUBSIDIO", 
    "TIPO DE POSTULO",  
    " NUMERO DE CUENTA", 
    "INSTITUCION FINANCIERA"
FROM POSTULANTE_35
WHERE "PUNTAJE TOTAL" > (SELECT AVG("PUNTAJE TOTAL") FROM POSTULANTE_35);







------------------------------------------ 3.6 CUADRO COMPARATIVO ------------------------------------------
SELECT 
    TO_CHAR(PS.FECHA_RECEPCION,'YYYY') A�O,
    SUM((SELECT COUNT(*)FROM TITULO_TRAMO WHERE OP_TITULO='TITULO I TRAMO 1' AND ID_COMUNA = CO.ID_COMUNA))"TITULO_I_TRAMO_1",
    SUM((SELECT COUNT(*)FROM TITULO_TRAMO WHERE OP_TITULO='TITULO I TRAMO 2' AND ID_COMUNA = CO.ID_COMUNA))"TITULO_I_TRAMO_2",
    SUM((SELECT COUNT(*)FROM TITULO_TRAMO WHERE OP_TITULO='TITULO II' AND ID_COMUNA = CO.ID_COMUNA))"TITULO_II",
    SUM((SELECT COUNT(*)FROM TITULO_TRAMO WHERE OP_TITULO='TITULO I TRAMO 1' AND ID_COMUNA = CO.ID_COMUNA) + 
    (SELECT COUNT(*)FROM TITULO_TRAMO WHERE OP_TITULO='TITULO I TRAMO 2' AND ID_COMUNA = CO.ID_COMUNA) +
    (SELECT COUNT(*)FROM TITULO_TRAMO WHERE OP_TITULO='TITULO II' AND ID_COMUNA = CO.ID_COMUNA)) "TOTAL"
FROM POSTULACION_SUBSIDIO PS
JOIN TITULO_TRAMO TT
    ON TT.ID_TITULO = PS.ID_TITULO
JOIN COMUNA CO 
    ON TT.ID_COMUNA = CO.ID_COMUNA
GROUP BY TO_CHAR(PS.FECHA_RECEPCION,'YYYY');

----------------------- CON SENTENCIA SET LIMITADAS A CONSULTA POR A�O -----------------------

SELECT 
    TO_CHAR(PS.FECHA_RECEPCION,'YYYY') A�O,
    SUM((SELECT COUNT(*)FROM TITULO_TRAMO WHERE OP_TITULO='TITULO I TRAMO 1' AND ID_COMUNA = CO.ID_COMUNA))"TITULO_I_TRAMO_1",
    SUM((SELECT COUNT(*)FROM TITULO_TRAMO WHERE OP_TITULO='TITULO I TRAMO 2' AND ID_COMUNA = CO.ID_COMUNA))"TITULO_I_TRAMO_2",
    SUM((SELECT COUNT(*)FROM TITULO_TRAMO WHERE OP_TITULO='TITULO II' AND ID_COMUNA = CO.ID_COMUNA))"TITULO_II",
    SUM((SELECT COUNT(*)FROM TITULO_TRAMO WHERE OP_TITULO='TITULO I TRAMO 1' AND ID_COMUNA = CO.ID_COMUNA) + 
    (SELECT COUNT(*)FROM TITULO_TRAMO WHERE OP_TITULO='TITULO I TRAMO 2' AND ID_COMUNA = CO.ID_COMUNA) +
    (SELECT COUNT(*)FROM TITULO_TRAMO WHERE OP_TITULO='TITULO II' AND ID_COMUNA = CO.ID_COMUNA)) "TOTAL"
FROM POSTULACION_SUBSIDIO PS
JOIN TITULO_TRAMO TT
    ON TT.ID_TITULO = PS.ID_TITULO
JOIN COMUNA CO 
    ON TT.ID_COMUNA = CO.ID_COMUNA
WHERE TO_CHAR(PS.FECHA_RECEPCION,'YYYY') = EXTRACT (YEAR FROM SYSDATE)
GROUP BY TO_CHAR(PS.FECHA_RECEPCION,'YYYY')

UNION 

SELECT 
    TO_CHAR(PS.FECHA_RECEPCION,'YYYY') A�O,
    SUM((SELECT COUNT(*)FROM TITULO_TRAMO WHERE OP_TITULO='TITULO I TRAMO 1' AND ID_COMUNA = CO.ID_COMUNA))"TITULO_I_TRAMO_1",
    SUM((SELECT COUNT(*)FROM TITULO_TRAMO WHERE OP_TITULO='TITULO I TRAMO 2' AND ID_COMUNA = CO.ID_COMUNA))"TITULO_I_TRAMO_2",
    SUM((SELECT COUNT(*)FROM TITULO_TRAMO WHERE OP_TITULO='TITULO II' AND ID_COMUNA = CO.ID_COMUNA))"TITULO_II",
    SUM((SELECT COUNT(*)FROM TITULO_TRAMO WHERE OP_TITULO='TITULO I TRAMO 1' AND ID_COMUNA = CO.ID_COMUNA) + 
    (SELECT COUNT(*)FROM TITULO_TRAMO WHERE OP_TITULO='TITULO I TRAMO 2' AND ID_COMUNA = CO.ID_COMUNA) +
    (SELECT COUNT(*)FROM TITULO_TRAMO WHERE OP_TITULO='TITULO II' AND ID_COMUNA = CO.ID_COMUNA)) "TOTAL"
FROM POSTULACION_SUBSIDIO PS
JOIN TITULO_TRAMO TT
    ON TT.ID_TITULO = PS.ID_TITULO
JOIN COMUNA CO 
    ON TT.ID_COMUNA = CO.ID_COMUNA
WHERE TO_CHAR(PS.FECHA_RECEPCION,'YYYY') = EXTRACT (YEAR FROM SYSDATE)-1
GROUP BY TO_CHAR(PS.FECHA_RECEPCION,'YYYY')
ORDER BY A�O ;
    
    
    
    

------------------------------------------ 3.7 ACTUALIZACION DEL ESTADO ------------------------------------------
-- UTILIZA VISTA DE SUBCONSULTA --    
SELECT 
    PS.NRO_FOLIO_POST,
    POST.RUT_POSTULANTE,
    POST.DV_RUT_POSTULANTE, 
    POST.FECHA_NAC, 
    POST.P_NOMBRE, 
    POST.S_NOMBRE, 
    POST.A_PATERNO, 
    POST.A_MATERNO, 
    POST.DIRECCION, 
    POST.ESTADO_CIVIL, 
    POST.ID_COMUNA, 
    POST.TEL_TRABAJO, 
    POST.TEL_DOMICILIO, 
    POST.CELULAR, 
    POST.CORREO, 
    POST.ID_NACIONALIDAD, 
    POST.ID_PUEBLO_ORIGIN, 
    POST.ID_ACREDI, 
    POST.SUELDO,
    CASE
        WHEN (PE.PUNTAJE + PC.PUNTAJE + PEC.PUNTAJE + NVL(PP.PUNTAJE,0) + PA.PUNTAJE + PT.PUNTAJE) > (SELECT * FROM PROMEDIO) THEN 1
        WHEN (PE.PUNTAJE + PC.PUNTAJE + PEC.PUNTAJE + NVL(PP.PUNTAJE,0) + PA.PUNTAJE + PT.PUNTAJE) BETWEEN (SELECT * FROM PROMEDIO)-400 AND (SELECT * FROM PROMEDIO)THEN 2
        ELSE 3
    END ID_SITUACION_SUB
  
FROM IDEN_POSTULANTE POST

JOIN PUNTAJE_EDAD PE 
    ON TRUNC (MONTHS_BETWEEN(SYSDATE,POST.FECHA_NAC)/12) BETWEEN PE.RANGO_MIN AND PE.RANGO_MAX    
LEFT JOIN CARGAS_FAMILIARES CF 
    ON POST.RUT_POSTULANTE = CF.RUT_POSTULANTE      
JOIN PUNTAJE_CARGAS PC 
    ON (SELECT COUNT(RUT_CARGA) FROM CARGAS_FAMILIARES WHERE POST.RUT_POSTULANTE = CF.RUT_POSTULANTE) BETWEEN PC.RANGO_MIN AND PC.RANGO_MAX
JOIN PUNTAJE_ESTADO_CIVIL PEC
    ON POST.ESTADO_CIVIL IN PEC.DESCRIPCION    
LEFT JOIN PUEBLO_ORIGINARIO POR
    ON POST.ID_PUEBLO_ORIGIN = POR.ID_PUEBLO_ORIGIN    
LEFT JOIN PUNTAJE_PUEBLO PP
    ON POR.INDIGENA_ORIGINARIO = PP.DESCRIPCION
JOIN CTA_DE_AHORRO CDA
    ON POST.RUT_POSTULANTE = CDA.RUT_POSTULANTE
JOIN PUNTAJE_AHORRO PA
    ON MONTO_AHORRADO BETWEEN MONTO_MIN AND MONTO_MAX    
JOIN TITULO T
    ON POST.ID_ACREDI = T.ID_ACREDI
LEFT JOIN PUNTAJE_TITULO PT
    ON T.TIPO_TITULO = PT.DESCRPCION
LEFT JOIN COMUNA CO
    ON CO.ID_COMUNA = POST.ID_COMUNA    
LEFT JOIN CARACT_VIVIENDA CV
    ON CO.ID_COMUNA = CV.ID_COMUNA
LEFT JOIN REGION REG
    ON REG.ID_REGION = CO.ID_REGION
LEFT JOIN REGION_EXTREMA REGX
    ON REG.NOM_REGION IN REGX.REGION
JOIN postulacion_subsidio PS
    ON POST.RUT_POSTULANTE = PS.RUT_POSTULANTE

GROUP BY PS.NRO_FOLIO_POST,
    POST.RUT_POSTULANTE,
    POST.DV_RUT_POSTULANTE, 
    POST.FECHA_NAC, 
    POST.P_NOMBRE, 
    POST.S_NOMBRE, 
    POST.A_PATERNO, 
    POST.A_MATERNO, 
    POST.DIRECCION, 
    POST.ESTADO_CIVIL, 
    POST.ID_COMUNA, 
    POST.TEL_TRABAJO, 
    POST.TEL_DOMICILIO, 
    POST.CELULAR, 
    POST.CORREO, 
    POST.ID_NACIONALIDAD, 
    POST.ID_PUEBLO_ORIGIN, 
    POST.ID_ACREDI, 
    POST.SUELDO,
    (PE.PUNTAJE + PC.PUNTAJE + PEC.PUNTAJE + NVL(PP.PUNTAJE,0) + PA.PUNTAJE + PT.PUNTAJE);



  _____      _       ____   ___   _       ___   _____    ___      _____   _         _____   _   _   _____    ___    ____    ___      _      _     
 |  ___|    / \     / ___| |_ _| | |     |_ _| |_   _|  / _ \    | ____| | |       |_   _| | | | | |_   _|  / _ \  |  _ \  |_ _|    / \    | |    
 | |_      / _ \   | |      | |  | |      | |    | |   | | | |   |  _|   | |         | |   | | | |   | |   | | | | | |_) |  | |    / _ \   | |    
 |  _|    / ___ \  | |___   | |  | |___   | |    | |   | |_| |   | |___  | |___      | |   | |_| |   | |   | |_| | |  _ <   | |   / ___ \  | |___ 
 |_|     /_/   \_\  \____| |___| |_____| |___|   |_|    \___/    |_____| |_____|     |_|    \___/    |_|    \___/  |_| \_\ |___| /_/   \_\ |_____|
 
 
 
 
 
 