--------------------------JOIN PLAN ESTUDIO-----------------------------

select *
	from PLAN_ESTUDIO;

	/* 
		id_tipo_carrera -- Carreras
		nombre_carrera -- Carreras
		id_facultad -- Carreras
		nombre_facultad -- Facultades
		nombre_grado -- Grados
		nombre_estado_plan_estudio --Estado_Plan_Estudio
		nombre_usuario -- Usuario
		nombre_puesto -- Puestos
		nombre_departamento -- Departamentos

		*/

select 
	--Plan_Estudio
	PE.*,
	--Carreras
	C.id_tipo_carrera,
	C.nombre_carrera,
	C.id_facultad,
	--Facultades
	F.nombre_facultad,
	--Grados
	G.nombre_grado,
	--Plan_Estudio
	E.nombre_estado_plan_estudio,
	--Usuarios
	U.nombre_usuario,
	--Puestos
	P.nombre_puesto,
	--Departamentos
	D.nombre_departamento
from 
	PLAN_ESTUDIO PE,
	CARRERAS C, 
	FACULTADES F, 
	GRADOS G,
	ESTADOS_PLAN_ESTUDIO E,
	USUARIOS U, 
	PUESTOS P, 
	DEPARTAMENTOS D
where 
	 PE.id_carrera = C.id_carrera
    AND C.id_facultad = F.id_facultad
    AND PE.id_grado = G.id_grado
	AND PE.id_estado_plan_estudio = E.id_estado_plan_estudio
    AND PE.id_usuario_aprobacion = U.id_usuario
    AND PE.id_puesto_aprobacion = P.id_puesto
    AND PE.id_departamento_aprobacion = D.id_departamento;


	--------------------------JOIN PLAN ESTUDIO DETALLE-----------------------------

Select * 
	from PLAN_ESTUDIO_DETALLE;

/*
codigo_curso_origen --Cursos
nombre_curso --Cursos
id_tipo_curso --Cursos
nombre_tipo_curso --Tipos_Cursos
fecha_creacion --Cursos
cantidad_horas --Plan_Estudio_Detalle
cantidad_creditos --Plan_Estudio_Detalle
*/


select
    -- Todo de detalle
    PED.id_plan_estudio_detalle,
    PED.id_plan_estudio,
    PED.numero_bloque,
    PED.id_curso,
    PED.cantidad_creditos,
    PED.cantidad_horas,
    PED.es_activo,

    -- Cursos
    C.codigo_curso_origen,
    C.nombre_curso,
    C.id_tipo_curso,
    C.fecha_creacion,

    -- Tipo curso
    TC.nombre_tipo_curso

from
    PLAN_ESTUDIO_DETALLE PED,
    CURSOS C,
    TIPOS_CURSOS TC

where 
    PED.id_curso = C.id_curso
    AND C.id_tipo_curso = TC.id_tipo_curso;

		--------------------------CRUD GRUPAL-------------------------------

		--------------------------PLAN ESTUDIO-------------------------------

		--------------------------CREATE (Emily)-----------------------------
       CREATE PROCEDURE sp_create_plan_estudio
(
    @id_plan_estudio INT,
    @id_carrera INT,
    @id_grado INT,
    @id_estado_plan_estudio INT,
    @id_usuario_aprobacion INT,
    @id_puesto_aprobacion INT,
    @id_departamento_aprobacion INT
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- VALIDACIONES
        IF @id_plan_estudio IS NULL
        BEGIN
            PRINT 'Error: ID es obligatorio';
            ROLLBACK;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM PLAN_ESTUDIO WHERE id_plan_estudio = @id_plan_estudio)
        BEGIN
            PRINT 'Error: Ya existe ese ID';
            ROLLBACK;
            RETURN;
        END

        IF @id_carrera IS NULL OR @id_grado IS NULL OR @id_estado_plan_estudio IS NULL
        BEGIN
            PRINT 'Error: Campos obligatorios faltantes';
            ROLLBACK;
            RETURN;
        END

        -- INSERT
        INSERT INTO PLAN_ESTUDIO
        (
            id_plan_estudio,
            id_carrera,
            id_grado,
            id_estado_plan_estudio,
            id_usuario_aprobacion,
            id_puesto_aprobacion,
            id_departamento_aprobacion
        )
        VALUES
        (
            @id_plan_estudio,
            @id_carrera,
            @id_grado,
            @id_estado_plan_estudio,
            @id_usuario_aprobacion,
            @id_puesto_aprobacion,
            @id_departamento_aprobacion
        );

        PRINT 'Plan de estudio creado correctamente';
        COMMIT;

    END TRY
    BEGIN CATCH
        ROLLBACK;
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

IF NOT EXISTS (SELECT 1 FROM CARRERAS WHERE id_carrera = @id_carrera)

		--------------------------READ (Marvin)-----------------------------

create procedure sp_read_plan_estudio
as
begin
select
     -- Todos los campos de la tabla
    PE.*,
    -- Carrera
    C.id_tipo_carrera,
    C.nombre_carrera,
    C.id_facultad,
    -- Facultad
    F.nombre_facultad,
    -- Grado
    G.nombre_grado,
    -- Estado
    E.nombre_estado_plan_estudio,
    -- Usuario
    U.nombre_usuario,
    -- Puesto
    P.nombre_puesto,
    -- Departamento
    D.nombre_departamento

from
    PLAN_ESTUDIO PE,
    CARRERAS C,
    FACULTADES F,
    GRADOS G,
    ESTADOS_PLAN_ESTUDIO E,
    USUARIOS U,
    PUESTOS P,
    DEPARTAMENTOS D

where
    PE.id_carrera = C.id_carrera
    AND C.id_facultad = F.id_facultad
    AND PE.id_grado = G.id_grado
    AND PE.id_estado_plan_estudio = E.id_estado_plan_estudio
    AND PE.id_usuario_aprobacion = U.id_usuario
    AND PE.id_puesto_aprobacion = P.id_puesto
    AND PE.id_departamento_aprobacion = D.id_departamento;
end;
go

		--------------------------UPDATE (Milton)----------------------------
CREATE OR ALTER PROCEDURE sp_update_plan_estudio
(
    @id_plan_estudio INT,
    @id_carrera INT,
    @id_grado INT,
    @id_estado_plan_estudio INT,
    @id_usuario_aprobacion INT = NULL,
    @id_puesto_aprobacion INT = NULL,
    @id_departamento_aprobacion INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;

        -- =========================================================
        -- VALIDACIÓN 1: Campos obligatorios (NOT NULL)
        -- =========================================================
        
        -- Verificar que el ID del plan de estudio NO sea NULL
        IF @id_plan_estudio IS NULL
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO]: El campo "id_plan_estudio" es obligatorio. No puede estar vacío.';
            PRINT 'Solución: Proporcione un valor numérico entero para identificar el plan de estudio a actualizar.';
            ROLLBACK;
            RETURN;
        END

        -- Verificar que el ID de la carrera NO sea NULL
        IF @id_carrera IS NULL
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO]: El campo "id_carrera" es obligatorio. No puede estar vacío.';
            PRINT 'Solución: Proporcione un ID de carrera válido existente en la tabla CARRERAS.';
            ROLLBACK;
            RETURN;
        END

        -- Verificar que el ID del grado NO sea NULL
        IF @id_grado IS NULL
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO]: El campo "id_grado" es obligatorio. No puede estar vacío.';
            PRINT 'Solución: Proporcione un ID de grado válido existente en la tabla GRADOS.';
            ROLLBACK;
            RETURN;
        END

        -- Verificar que el ID del estado NO sea NULL
        IF @id_estado_plan_estudio IS NULL
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO]: El campo "id_estado_plan_estudio" es obligatorio. No puede estar vacío.';
            PRINT 'Solución: Proporcione un ID de estado válido existente en la tabla ESTADOS_PLAN_ESTUDIO.';
            ROLLBACK;
            RETURN;
        END


        -- VALIDACIÓN 2: Validación de contenido de datos (tipos y rangos)
     
        
        -- Validar que los IDs sean números positivos (enteros mayores a 0)
        IF @id_plan_estudio <= 0
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO]: El campo "id_plan_estudio" debe ser un número entero mayor a 0.';
            PRINT 'Valor recibido: ' + ISNULL(CAST(@id_plan_estudio AS VARCHAR), 'NULL');
            PRINT 'Solución: Use números positivos como 1, 2, 3, etc.';
            ROLLBACK;
            RETURN;
        END

        IF @id_carrera <= 0
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO]: El campo "id_carrera" debe ser un número entero mayor a 0.';
            PRINT 'Valor recibido: ' + ISNULL(CAST(@id_carrera AS VARCHAR), 'NULL');
            PRINT 'Solución: Consulte la tabla CARRERAS para obtener IDs válidos.';
            ROLLBACK;
            RETURN;
        END

        IF @id_grado <= 0
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO]: El campo "id_grado" debe ser un número entero mayor a 0.';
            PRINT 'Valor recibido: ' + ISNULL(CAST(@id_grado AS VARCHAR), 'NULL');
            PRINT 'Solución: Consulte la tabla GRADOS para obtener IDs válidos.';
            ROLLBACK;
            RETURN;
        END

        IF @id_estado_plan_estudio <= 0
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO]: El campo "id_estado_plan_estudio" debe ser un número entero mayor a 0.';
            PRINT 'Valor recibido: ' + ISNULL(CAST(@id_estado_plan_estudio AS VARCHAR), 'NULL');
            PRINT 'Solución: Consulte la tabla ESTADOS_PLAN_ESTUDIO para obtener IDs válidos.';
            ROLLBACK;
            RETURN;
        END

        -- Validar campos opcionales si fueron proporcionados
        IF @id_usuario_aprobacion IS NOT NULL AND @id_usuario_aprobacion <= 0
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO]: El campo "id_usuario_aprobacion" debe ser un número entero mayor a 0.';
            PRINT 'Valor recibido: ' + CAST(@id_usuario_aprobacion AS VARCHAR);
            PRINT 'Solución: Proporcione un ID de usuario válido o deje el campo como NULL.';
            ROLLBACK;
            RETURN;
        END

        IF @id_puesto_aprobacion IS NOT NULL AND @id_puesto_aprobacion <= 0
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO]: El campo "id_puesto_aprobacion" debe ser un número entero mayor a 0.';
            PRINT 'Valor recibido: ' + CAST(@id_puesto_aprobacion AS VARCHAR);
            PRINT 'Solución: Proporcione un ID de puesto válido o deje el campo como NULL.';
            ROLLBACK;
            RETURN;
        END

        IF @id_departamento_aprobacion IS NOT NULL AND @id_departamento_aprobacion <= 0
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO]: El campo "id_departamento_aprobacion" debe ser un número entero mayor a 0.';
            PRINT 'Valor recibido: ' + CAST(@id_departamento_aprobacion AS VARCHAR);
            PRINT 'Solución: Proporcione un ID de departamento válido o deje el campo como NULL.';
            ROLLBACK;
            RETURN;
        END


        -- VALIDACIÓN 3: Verificar que los registros existan en las tablas relacionadas

        
        -- Verificar que el registro a actualizar existe
        IF NOT EXISTS (SELECT 1 FROM PLAN_ESTUDIO WHERE id_plan_estudio = @id_plan_estudio)
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO]: No existe un plan de estudio con el ID especificado.';
            PRINT 'ID proporcionado: ' + CAST(@id_plan_estudio AS VARCHAR);
            PRINT 'Solución: Verifique que el ID sea correcto. Use SP_READ_PLAN_ESTUDIO para listar los existentes.';
            ROLLBACK;
            RETURN;
        END

        -- Verificar que la carrera existe
        IF NOT EXISTS (SELECT 1 FROM CARRERAS WHERE id_carrera = @id_carrera)
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO]: La carrera especificada no existe en la base de datos.';
            PRINT 'ID de carrera proporcionado: ' + CAST(@id_carrera AS VARCHAR);
            PRINT 'Solución: Consulte la tabla CARRERAS para obtener IDs válidos.';
            ROLLBACK;
            RETURN;
        END

        -- Verificar que el grado existe
        IF NOT EXISTS (SELECT 1 FROM GRADOS WHERE id_grado = @id_grado)
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO]: El grado especificado no existe en la base de datos.';
            PRINT 'ID de grado proporcionado: ' + CAST(@id_grado AS VARCHAR);
            PRINT 'Solución: Consulte la tabla GRADOS para obtener IDs válidos.';
            ROLLBACK;
            RETURN;
        END

        -- Verificar que el estado existe
        IF NOT EXISTS (SELECT 1 FROM ESTADOS_PLAN_ESTUDIO WHERE id_estado_plan_estudio = @id_estado_plan_estudio)
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO]: El estado especificado no existe en la base de datos.';
            PRINT 'ID de estado proporcionado: ' + CAST(@id_estado_plan_estudio AS VARCHAR);
            PRINT 'Solución: Consulte la tabla ESTADOS_PLAN_ESTUDIO para obtener IDs válidos.';
            ROLLBACK;
            RETURN;
        END

        -- Verificar usuario si fue proporcionado
        IF @id_usuario_aprobacion IS NOT NULL 
           AND NOT EXISTS (SELECT 1 FROM USUARIOS WHERE id_usuario = @id_usuario_aprobacion)
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO]: El usuario especificado no existe en la base de datos.';
            PRINT 'ID de usuario proporcionado: ' + CAST(@id_usuario_aprobacion AS VARCHAR);
            PRINT 'Solución: Consulte la tabla USUARIOS para obtener IDs válidos o deje el campo como NULL.';
            ROLLBACK;
            RETURN;
        END

        -- Verificar puesto si fue proporcionado
        IF @id_puesto_aprobacion IS NOT NULL 
           AND NOT EXISTS (SELECT 1 FROM PUESTOS WHERE id_puesto = @id_puesto_aprobacion)
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO]: El puesto especificado no existe en la base de datos.';
            PRINT 'ID de puesto proporcionado: ' + CAST(@id_puesto_aprobacion AS VARCHAR);
            PRINT 'Solución: Consulte la tabla PUESTOS para obtener IDs válidos o deje el campo como NULL.';
            ROLLBACK;
            RETURN;
        END

        -- Verificar departamento si fue proporcionado
        IF @id_departamento_aprobacion IS NOT NULL 
           AND NOT EXISTS (SELECT 1 FROM DEPARTAMENTOS WHERE id_departamento = @id_departamento_aprobacion)
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO]: El departamento especificado no existe en la base de datos.';
            PRINT 'ID de departamento proporcionado: ' + CAST(@id_departamento_aprobacion AS VARCHAR);
            PRINT 'Solución: Consulte la tabla DEPARTAMENTOS para obtener IDs válidos o deje el campo como NULL.';
            ROLLBACK;
            RETURN;
        END

        UPDATE PLAN_ESTUDIO
        SET 
            id_carrera = @id_carrera,
            id_grado = @id_grado,
            id_estado_plan_estudio = @id_estado_plan_estudio,
            id_usuario_aprobacion = @id_usuario_aprobacion,
            id_puesto_aprobacion = @id_puesto_aprobacion,
            id_departamento_aprobacion = @id_departamento_aprobacion
        WHERE 
            id_plan_estudio = @id_plan_estudio;

        PRINT 'ÉXITO: Plan de estudio actualizado correctamente.';
        PRINT 'ID actualizado: ' + CAST(@id_plan_estudio AS VARCHAR);
        COMMIT;

    END TRY
    BEGIN CATCH
        ROLLBACK;
        PRINT 'ERROR INESPERADO [PLAN_ESTUDIO]: ' + ERROR_MESSAGE();
        PRINT 'Código de error: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Línea: ' + CAST(ERROR_LINE() AS VARCHAR);
    END CATCH
END;
GO

---PRUEBAS DE VALIDACIÓN - PLAN_ESTUDIO---


-- PRUEBA 1: Campos obligatorios NULL

EXEC sp_update_plan_estudio 
    @id_plan_estudio = 1,
    @id_carrera = NULL,
    @id_grado = 2,
    @id_estado_plan_estudio = 1;
GO

-- PRUEBA 2: ID negativo

EXEC sp_update_plan_estudio 
    @id_plan_estudio = -5,
    @id_carrera = 1,
    @id_grado = 2,
    @id_estado_plan_estudio = 1;
GO

-- PRUEBA 3: ID que no existe

EXEC sp_update_plan_estudio 
    @id_plan_estudio = 9999,
    @id_carrera = 1,
    @id_grado = 2,
    @id_estado_plan_estudio = 1;
GO

-- PRUEBA 4: Carrera que no existe

EXEC sp_update_plan_estudio 
    @id_plan_estudio = 1,
    @id_carrera = 9999,
    @id_grado = 2,
    @id_estado_plan_estudio = 1;
GO

		--------------------------DELETE (Sofia)-----------------------------
        /* =========================================================
   DELETE TABLA MAESTRA: PLAN_ESTUDIO
========================================================= */
CREATE PROCEDURE SP_DELETE_PLAN_ESTUDIO
    @id_plan_estudio INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DELETE FROM PLAN_ESTUDIO
        WHERE id_plan_estudio = @id_plan_estudio;

        PRINT 'PLAN_ESTUDIO eliminado correctamente.';
    END TRY

    BEGIN CATCH
        PRINT 'Error al eliminar PLAN_ESTUDIO.';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

		--------------------------PLAN ESTUDIO DETALLE-----------------------

		--------------------------CREATE (Emily)-----------------------------
    CREATE PROCEDURE sp_create_plan_estudio_detalle
(
    @id_plan_estudio_detalle INT,
    @id_plan_estudio INT,
    @numero_bloque INT,
    @id_curso INT,
    @cantidad_creditos INT,
    @cantidad_horas INT,
    @es_activo BIT
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- VALIDACIONES
        IF @id_plan_estudio_detalle IS NULL
        BEGIN
            PRINT 'Error: ID detalle es obligatorio';
            ROLLBACK;
            RETURN;
        END

        IF EXISTS (
            SELECT 1 
            FROM PLAN_ESTUDIO_DETALLE 
            WHERE id_plan_estudio_detalle = @id_plan_estudio_detalle
        )
        BEGIN
            PRINT 'Error: Ya existe ese ID';
            ROLLBACK;
            RETURN;
        END

        IF @id_plan_estudio IS NULL OR @id_curso IS NULL
        BEGIN
            PRINT 'Error: Campos obligatorios faltantes';
            ROLLBACK;
            RETURN;
        END

        IF @cantidad_creditos <= 0 OR @cantidad_horas <= 0
        BEGIN
            PRINT 'Error: Créditos y horas deben ser mayores a 0';
            ROLLBACK;
            RETURN;
        END

        IF @es_activo IS NULL
        BEGIN
            PRINT 'Error: Estado activo es obligatorio';
            ROLLBACK;
            RETURN;
        END

        -- INSERT
        INSERT INTO PLAN_ESTUDIO_DETALLE
        (
            id_plan_estudio_detalle,
            id_plan_estudio,
            numero_bloque,
            id_curso,
            cantidad_creditos,
            cantidad_horas,
            es_activo
        )
        VALUES
        (
            @id_plan_estudio_detalle,
            @id_plan_estudio,
            @numero_bloque,
            @id_curso,
            @cantidad_creditos,
            @cantidad_horas,
            @es_activo
        );

        PRINT 'Detalle creado correctamente';
        COMMIT;

    END TRY
    BEGIN CATCH
        ROLLBACK;
        PRINT 'Error: ' + ERROR_MESSAGE();
    END CATCH
END;
GO

PRINT 'PRUEBA CREATE PLAN ESTUDIO DETALLE';

EXEC sp_create_plan_estudio_detalle
1, 1, 1, 1, 3, 48, 1;
GO

		--------------------------READ (Marvin)-----------------------------

create procedure sp_read_plan_estudio_detalle
as
begin
select

-- Todo de detalle
    PED.id_plan_estudio_detalle,
    PED.id_plan_estudio,
    PED.numero_bloque,
    PED.id_curso,
    PED.cantidad_creditos,
    PED.cantidad_horas,
    PED.es_activo,

    -- Cursos
    C.codigo_curso_origen,
    C.nombre_curso,
    C.id_tipo_curso,
    C.fecha_creacion,

    -- Tipo curso
    TC.nombre_tipo_curso

from
    PLAN_ESTUDIO_DETALLE PED,
    CURSOS C,
    TIPOS_CURSOS TC
where 
    PED.id_curso = C.id_curso
    AND C.id_tipo_curso = TC.id_tipo_curso;
end;
go

		--------------------------UPDATE (Milton)----------------------------
    CREATE OR ALTER PROCEDURE sp_update_plan_estudio_detalle
(
    @id_plan_estudio_detalle INT,
    @id_plan_estudio INT,
    @numero_bloque INT = NULL,
    @id_curso INT,
    @cantidad_creditos INT,
    @cantidad_horas INT,
    @es_activo BIT
)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;


        -- VALIDACIÓN 1: Campos obligatorios (NOT NULL)--

        
        -- Verificar que el ID del detalle NO sea NULL
        IF @id_plan_estudio_detalle IS NULL
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO_DETALLE]: El campo "id_plan_estudio_detalle" es obligatorio. No puede estar vacío.';
            PRINT 'Solución: Proporcione un valor numérico entero para identificar el detalle a actualizar.';
            ROLLBACK;
            RETURN;
        END

        -- Verificar que el ID del plan de estudio NO sea NULL--
        IF @id_plan_estudio IS NULL
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO_DETALLE]: El campo "id_plan_estudio" es obligatorio. No puede estar vacío.';
            PRINT 'Solución: Proporcione un ID de plan de estudio válido existente en la tabla PLAN_ESTUDIO.';
            ROLLBACK;
            RETURN;
        END

        -- Verificar que el ID del curso NO sea NULL--
        IF @id_curso IS NULL
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO_DETALLE]: El campo "id_curso" es obligatorio. No puede estar vacío.';
            PRINT 'Solución: Proporcione un ID de curso válido existente en la tabla CURSOS.';
            ROLLBACK;
            RETURN;
        END

        -- Verificar que la cantidad de créditos NO sea NULL--
        IF @cantidad_creditos IS NULL
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO_DETALLE]: El campo "cantidad_creditos" es obligatorio. No puede estar vacío.';
            PRINT 'Solución: Proporcione un número entero mayor a 0 para los créditos.';
            ROLLBACK;
            RETURN;
        END

        -- Verificar que la cantidad de horas NO sea NULL---
        IF @cantidad_horas IS NULL
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO_DETALLE]: El campo "cantidad_horas" es obligatorio. No puede estar vacío.';
            PRINT 'Solución: Proporcione un número entero mayor a 0 para las horas.';
            ROLLBACK;
            RETURN;
        END

        -- Verificar que el estado activo NO sea NULL--
        IF @es_activo IS NULL
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO_DETALLE]: El campo "es_activo" es obligatorio. No puede estar vacío.';
            PRINT 'Solución: Proporcione 1 (activo) o 0 (inactivo) para este campo.';
            ROLLBACK;
            RETURN;
        END

  
        -- VALIDACIÓN 2: Validación de contenido de datos (tipos y rangos)---

        
        -- Validar que los IDs sean números positivos
        IF @id_plan_estudio_detalle <= 0
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO_DETALLE]: El campo "id_plan_estudio_detalle" debe ser un número entero mayor a 0.';
            PRINT 'Valor recibido: ' + ISNULL(CAST(@id_plan_estudio_detalle AS VARCHAR), 'NULL');
            PRINT 'Solución: Use números positivos como 1, 2, 3, etc.';
            ROLLBACK;
            RETURN;
        END

        IF @id_plan_estudio <= 0
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO_DETALLE]: El campo "id_plan_estudio" debe ser un número entero mayor a 0.';
            PRINT 'Valor recibido: ' + ISNULL(CAST(@id_plan_estudio AS VARCHAR), 'NULL');
            PRINT 'Solución: Consulte la tabla PLAN_ESTUDIO para obtener IDs válidos.';
            ROLLBACK;
            RETURN;
        END

        IF @id_curso <= 0
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO_DETALLE]: El campo "id_curso" debe ser un número entero mayor a 0.';
            PRINT 'Valor recibido: ' + ISNULL(CAST(@id_curso AS VARCHAR), 'NULL');
            PRINT 'Solución: Consulte la tabla CURSOS para obtener IDs válidos.';
            ROLLBACK;
            RETURN;
        END

        -- Validar créditos (debe ser mayor a 0 y típicamente no mayor a 10)
        IF @cantidad_creditos <= 0
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO_DETALLE]: La cantidad de créditos debe ser un número entero mayor a 0.';
            PRINT 'Valor recibido: ' + CAST(@cantidad_creditos AS VARCHAR);
            PRINT 'Solución: Los créditos suelen ser valores entre 1 y 10. Ejemplo: 3, 4, 5.';
            ROLLBACK;
            RETURN;
        END

        IF @cantidad_creditos > 20
        BEGIN
            PRINT 'ADVERTENCIA [PLAN_ESTUDIO_DETALLE]: La cantidad de créditos es muy alta (' + CAST(@cantidad_creditos AS VARCHAR) + ').';
            PRINT 'NOTA: Verifique que este valor sea correcto. Los créditos por curso normalmente no superan 10.';
        END

        -- Validar horas (debe ser mayor a 0)
        IF @cantidad_horas <= 0
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO_DETALLE]: La cantidad de horas debe ser un número entero mayor a 0.';
            PRINT 'Valor recibido: ' + CAST(@cantidad_horas AS VARCHAR);
            PRINT 'Solución: Las horas suelen ser múltiplos de 16 (48, 64, 80, etc.) o según normativa.';
            ROLLBACK;
            RETURN;
        END

        IF @cantidad_horas > 200
        BEGIN
            PRINT 'ADVERTENCIA [PLAN_ESTUDIO_DETALLE]: La cantidad de horas es muy alta (' + CAST(@cantidad_horas AS VARCHAR) + ').';
            PRINT 'NOTA: Verifique que este valor sea correcto. Un curso típico tiene entre 48 y 96 horas.';
        END

        -- Validar número de bloque (si se proporciona)
        IF @numero_bloque IS NOT NULL
        BEGIN
            IF @numero_bloque <= 0
            BEGIN
                PRINT 'ERROR [PLAN_ESTUDIO_DETALLE]: El número de bloque debe ser un número entero mayor a 0.';
                PRINT 'Valor recibido: ' + CAST(@numero_bloque AS VARCHAR);
                PRINT 'Solución: Los bloques suelen ser números consecutivos: 1, 2, 3, etc.';
                ROLLBACK;
                RETURN;
            END
            
            IF @numero_bloque > 12
            BEGIN
                PRINT 'ADVERTENCIA [PLAN_ESTUDIO_DETALLE]: El número de bloque (' + CAST(@numero_bloque AS VARCHAR) + ') es inusualmente alto.';
                PRINT 'NOTA: Un plan de estudio típico tiene entre 8 y 10 bloques o semestres.';
            END
        END

        -- Validar relación horas vs créditos (regla de negocio común)
        -- Normalmente 1 crédito = 16 horas
        DECLARE @horas_esperadas INT = @cantidad_creditos * 16;
        IF ABS(@cantidad_horas - @horas_esperadas) > 8
        BEGIN
            PRINT 'ADVERTENCIA [PLAN_ESTUDIO_DETALLE]: La relación horas/créditos no es estándar.';
            PRINT 'Créditos: ' + CAST(@cantidad_creditos AS VARCHAR) + ' | Horas: ' + CAST(@cantidad_horas AS VARCHAR);
            PRINT 'Nota: Generalmente ' + CAST(@cantidad_creditos AS VARCHAR) + ' crédito(s) equivale a ' + CAST(@horas_esperadas AS VARCHAR) + ' horas.';
            PRINT 'Solución: Verifique que los valores sean correctos según la normativa institucional.';
        END

        -- VALIDACIÓN 3: Verificar que los registros existan en las tablas relacionadas
 
        -- Verificar que el registro a actualizar existe
        IF NOT EXISTS (SELECT 1 FROM PLAN_ESTUDIO_DETALLE WHERE id_plan_estudio_detalle = @id_plan_estudio_detalle)
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO_DETALLE]: No existe un detalle de plan de estudio con el ID especificado.';
            PRINT 'ID proporcionado: ' + CAST(@id_plan_estudio_detalle AS VARCHAR);
            PRINT 'Solución: Verifique que el ID sea correcto. Use SP_READ_PLAN_ESTUDIO_DETALLE para listar los existentes.';
            ROLLBACK;
            RETURN;
        END

        -- Verificar que el plan de estudio existe
        IF NOT EXISTS (SELECT 1 FROM PLAN_ESTUDIO WHERE id_plan_estudio = @id_plan_estudio)
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO_DETALLE]: El plan de estudio especificado no existe en la base de datos.';
            PRINT 'ID de plan de estudio proporcionado: ' + CAST(@id_plan_estudio AS VARCHAR);
            PRINT 'Solución: Consulte la tabla PLAN_ESTUDIO para obtener IDs válidos.';
            ROLLBACK;
            RETURN;
        END

        -- Verificar que el curso existe
        IF NOT EXISTS (SELECT 1 FROM CURSOS WHERE id_curso = @id_curso)
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO_DETALLE]: El curso especificado no existe en la base de datos.';
            PRINT 'ID de curso proporcionado: ' + CAST(@id_curso AS VARCHAR);
            PRINT 'Solución: Consulte la tabla CURSOS para obtener IDs válidos.';
            ROLLBACK;
            RETURN;
        END

        -- Verificar que no exista duplicado (mismo curso en el mismo plan)
        IF EXISTS (
            SELECT 1 FROM PLAN_ESTUDIO_DETALLE 
            WHERE id_plan_estudio = @id_plan_estudio 
              AND id_curso = @id_curso 
              AND id_plan_estudio_detalle != @id_plan_estudio_detalle
        )
        BEGIN
            PRINT 'ERROR [PLAN_ESTUDIO_DETALLE]: Ya existe un registro con el mismo curso en este plan de estudio.';
            PRINT 'Plan de estudio: ' + CAST(@id_plan_estudio AS VARCHAR) + ' | Curso: ' + CAST(@id_curso AS VARCHAR);
            PRINT 'Solución: No puede duplicar el mismo curso dentro del mismo plan de estudio.';
            ROLLBACK;
            RETURN;
        END

        UPDATE PLAN_ESTUDIO_DETALLE
        SET 
            id_plan_estudio = @id_plan_estudio,
            numero_bloque = @numero_bloque,
            id_curso = @id_curso,
            cantidad_creditos = @cantidad_creditos,
            cantidad_horas = @cantidad_horas,
            es_activo = @es_activo
        WHERE 
            id_plan_estudio_detalle = @id_plan_estudio_detalle;

        PRINT 'ÉXITO: Detalle de plan de estudio actualizado correctamente.';
        PRINT 'ID detalle actualizado: ' + CAST(@id_plan_estudio_detalle AS VARCHAR);
        PRINT 'Curso: ' + CAST(@id_curso AS VARCHAR) + ' | Créditos: ' + CAST(@cantidad_creditos AS VARCHAR) + ' | Horas: ' + CAST(@cantidad_horas AS VARCHAR);
        COMMIT;

    END TRY
    BEGIN CATCH
        ROLLBACK;
        PRINT 'ERROR INESPERADO [PLAN_ESTUDIO_DETALLE]: ' + ERROR_MESSAGE();
        PRINT 'Código de error: ' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT 'Línea: ' + CAST(ERROR_LINE() AS VARCHAR);
    END CATCH
END;
GO

--Validacion--

-- PRUEBA 1: Campos obligatorios NULL

EXEC sp_update_plan_estudio 
    @id_plan_estudio = 1,
    @id_carrera = NULL,
    @id_grado = 2,
    @id_estado_plan_estudio = 1;
GO

-- PRUEBA 2: ID negativo

EXEC sp_update_plan_estudio 
    @id_plan_estudio = -5,
    @id_carrera = 1,
    @id_grado = 2,
    @id_estado_plan_estudio = 1;
GO

-- PRUEBA 3: ID que no existe

EXEC sp_update_plan_estudio 
    @id_plan_estudio = 9999,
    @id_carrera = 1,
    @id_grado = 2,
    @id_estado_plan_estudio = 1;
GO

-- PRUEBA 4: Carrera que no existe

EXEC sp_update_plan_estudio 
    @id_plan_estudio = 1,
    @id_carrera = 9999,
    @id_grado = 2,
    @id_estado_plan_estudio = 1;
GO

-- PRUEBA 5: Cantidad de créditos negativa

EXEC sp_update_plan_estudio_detalle
    @id_plan_estudio_detalle = 1,
    @id_plan_estudio = 1,
    @id_curso = 1,
    @cantidad_creditos = -3,
    @cantidad_horas = 48,
    @es_activo = 1;
GO

-- PRUEBA 6 Cantidad de horas = 0 (inválido)

EXEC sp_update_plan_estudio_detalle
    @id_plan_estudio_detalle = 1,
    @id_plan_estudio = 1,
    @id_curso = 1,
    @cantidad_creditos = 3,
    @cantidad_horas = 0,
    @es_activo = 1;
GO

-- PRUEBA 7: ID detalle que no existe

EXEC sp_update_plan_estudio_detalle
    @id_plan_estudio_detalle = 9999,
    @id_plan_estudio = 1,
    @id_curso = 1,
    @cantidad_creditos = 3,
    @cantidad_horas = 48,
    @es_activo = 1;
GO

-- PRUEBA 8: Curso duplicado dentro del mismo plan

EXEC sp_update_plan_estudio_detalle
    @id_plan_estudio_detalle = 2,
    @id_plan_estudio = 1,
    @id_curso = 1,  
    @cantidad_creditos = 3,
    @cantidad_horas = 48,
    @es_activo = 1;
GO

		--------------------------DELETE (Sofia)-----------------------------
/* =========================================================
   DELETE TABLA DETALLE: PLAN_ESTUDIO_DETALLE
========================================================= */
CREATE PROCEDURE SP_DELETE_PLAN_ESTUDIO_DETALLE
    @id_plan_estudio_detalle INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DELETE FROM PLAN_ESTUDIO_DETALLE
        WHERE id_plan_estudio_detalle = @id_plan_estudio_detalle;

        PRINT 'PLAN_ESTUDIO_DETALLE eliminado correctamente.';
    END TRY

    BEGIN CATCH
        PRINT 'Error al eliminar PLAN_ESTUDIO_DETALLE.';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

		--------------------------CRUD INDIVIDUAL----------------------------

		-------------------------- MARVIN ----------------------------------
        ----CREATE----
create procedure sp_insertar_estado_programa_academico
    @p_id_estado_programa_academico int,
    @p_nombre_estado_programa_academico varchar(30),
    @p_es_activo bit
as
begin
    begin try
        begin transaction;

        if @p_id_estado_programa_academico is null
        begin
            print 'error: el id es obligatorio.';
            rollback;
            return;
        end

        if @p_nombre_estado_programa_academico is null 
           or trim(@p_nombre_estado_programa_academico) = ''
        begin
            print 'error: el nombre es obligatorio.';
            rollback;
            return;
        end

        if @p_es_activo is null
        begin
            print 'error: el estado activo es obligatorio.';
            rollback;
            return;
        end

        insert into estados_programas_academicos
        (id_estado_programa_academico, nombre_estado_programa_academico, es_activo)
        values
        (@p_id_estado_programa_academico, trim(@p_nombre_estado_programa_academico), @p_es_activo);

        print 'registro insertado correctamente.';

        commit;
    end try
    begin catch
        rollback;
        print 'error al insertar: ' + error_message();
    end catch
end;

----READ----
create procedure sp_obtener_estados_programas_academicos
    @p_id_estado_programa_academico int = null
as
begin
    begin try
        if @p_id_estado_programa_academico is null
        begin
            select * 
            from estados_programas_academicos;
        end
        else
        begin
            select * 
            from estados_programas_academicos
            where id_estado_programa_academico = @p_id_estado_programa_academico;

            if @@rowcount = 0
                print 'no se encontró el registro.';
        end
    end try
    begin catch
        print 'error al consultar: ' + error_message();
    end catch
end;

----UPDATE----
create procedure sp_actualizar_estado_programa_academico
    @p_id_estado_programa_academico int,
    @p_nombre_estado_programa_academico varchar(30),
    @p_es_activo bit
as
begin
    begin try
        begin transaction;

        -- validaciones
        if @p_id_estado_programa_academico is null
        begin
            print 'error: el id es obligatorio.';
            rollback;
            return;
        end

        if @p_nombre_estado_programa_academico is null 
           or trim(@p_nombre_estado_programa_academico) = ''
        begin
            print 'error: el nombre es obligatorio.';
            rollback;
            return;
        end

        if @p_es_activo is null
        begin
            print 'error: el estado activo es obligatorio.';
            rollback;
            return;
        end

        if not exists (
            select 1 
            from estados_programas_academicos
            where id_estado_programa_academico = @p_id_estado_programa_academico
        )
        begin
            print 'error: el registro no existe.';
            rollback;
            return;
        end

        update estados_programas_academicos
        set nombre_estado_programa_academico = trim(@p_nombre_estado_programa_academico),
            es_activo = @p_es_activo
        where id_estado_programa_academico = @p_id_estado_programa_academico;

        print 'registro actualizado correctamente.';

        commit;
    end try
    begin catch
        rollback;
        print 'error al actualizar: ' + error_message();
    end catch
end;

----DELETE----
create procedure sp_eliminar_estado_programa_academico
    @p_id_estado_programa_academico int
as
begin
    begin try
        begin transaction;

        if @p_id_estado_programa_academico is null
        begin
            print 'error: el id es obligatorio.';
            rollback;
            return;
        end

        if not exists (
            select 1 
            from estados_programas_academicos
            where id_estado_programa_academico = @p_id_estado_programa_academico
        )
        begin
            print 'error: el registro no existe.';
            rollback;
            return;
        end

        delete from estados_programas_academicos
        where id_estado_programa_academico = @p_id_estado_programa_academico;

        print 'registro eliminado correctamente.';

        commit;
    end try
    begin catch
        rollback;
        print 'error al eliminar: ' + error_message();
    end catch
end;

----PRUEBAS----

-- insertar válido
exec sp_insertar_estado_programa_academico 3, 'inactivo', 1;

-- consultar todos
exec sp_obtener_estados_programas_academicos;

-- consultar uno existente
exec sp_obtener_estados_programas_academicos 3;

-- actualizar correcto
exec sp_actualizar_estado_programa_academico 3, 'Inactivo', 0;

-- eliminar correcto
exec sp_eliminar_estado_programa_academico 3;

---- PRUEBAS DE ERROR ----

-- INSERT: id null
exec sp_insertar_estado_programa_academico null, 'Activo', 1;

-- INSERT: nombre vacío
exec sp_insertar_estado_programa_academico 10, '   ', 1;

-- INSERT: es_activo null
exec sp_insertar_estado_programa_academico 11, 'Activo', null;


-- UPDATE: id no existe
exec sp_actualizar_estado_programa_academico 999, 'Activo', 1;

-- UPDATE: nombre null
exec sp_actualizar_estado_programa_academico 1, null, 1;


-- DELETE: id no existe
exec sp_eliminar_estado_programa_academico 999;

-- DELETE: id null
exec sp_eliminar_estado_programa_academico null;



		-------------------------- SOFIA ----------------------------------
        /*
Autora: Sofia Saborio
Grupo 3 - Planes de Estudio
CRUD Individual - Tabla TIPOS_CURSOS
Procedimiento: CREATE
*/

CREATE PROCEDURE sp_tipos_cursos_sofia_saborio_create_20260421_1230
(
    @id_tipo_curso INT,
    @nombre_tipo_curso VARCHAR(30),
    @es_activo BIT
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validación ID obligatorio
        IF @id_tipo_curso IS NULL
        BEGIN
            PRINT 'Error: El id_tipo_curso es obligatorio.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validación nombre obligatorio
        IF @nombre_tipo_curso IS NULL OR LTRIM(RTRIM(@nombre_tipo_curso)) = ''
        BEGIN
            PRINT 'Error: El nombre_tipo_curso es obligatorio.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar duplicado ID
        IF EXISTS (SELECT 1 FROM TIPOS_CURSOS WHERE id_tipo_curso = @id_tipo_curso)
        BEGIN
            PRINT 'Error: Ya existe ese id_tipo_curso.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar duplicado nombre
        IF EXISTS (SELECT 1 FROM TIPOS_CURSOS WHERE nombre_tipo_curso = @nombre_tipo_curso)
        BEGIN
            PRINT 'Error: Ya existe ese nombre_tipo_curso.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        INSERT INTO TIPOS_CURSOS
        (
            id_tipo_curso,
            nombre_tipo_curso,
            es_activo
        )
        VALUES
        (
            @id_tipo_curso,
            @nombre_tipo_curso,
            @es_activo
        );

        COMMIT TRANSACTION;
        PRINT 'Registro insertado correctamente.';

    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al insertar.';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
/*
Autora: Sofia Saborio
Grupo 3 - Planes de Estudio
CRUD Individual - Tabla TIPOS_CURSOS
Procedimiento: READ
*/

USE SGIEDB;
GO

DROP PROCEDURE IF EXISTS dbo.sp_tipos_cursos_sofia_saborio_read_20260421_1240;
GO

CREATE PROCEDURE dbo.sp_tipos_cursos_sofia_saborio_read_20260421_1240
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        SELECT 
            id_tipo_curso,
            nombre_tipo_curso,
            es_activo
        FROM dbo.TIPOS_CURSOS
        ORDER BY id_tipo_curso;

    END TRY

    BEGIN CATCH
        PRINT 'Error al consultar datos.';
        PRINT ERROR_MESSAGE();

    END CATCH
END;
GO
/*
Autora: Sofia Saborio
Grupo 3 - Planes de Estudio
CRUD Individual - Tabla TIPOS_CURSOS
Procedimiento: UPDATE
Fecha: 21/04/2026
*/

USE SGIEDB;
GO

DROP PROCEDURE IF EXISTS dbo.sp_tipos_cursos_sofia_saborio_update_20260421_1300;
GO

CREATE PROCEDURE dbo.sp_tipos_cursos_sofia_saborio_update_20260421_1300
(
    @id_tipo_curso INT,
    @nombre_tipo_curso VARCHAR(30),
    @es_activo BIT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar ID obligatorio
        IF @id_tipo_curso IS NULL
        BEGIN
            PRINT 'Error: El id_tipo_curso es obligatorio.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar nombre obligatorio
        IF @nombre_tipo_curso IS NULL OR LTRIM(RTRIM(@nombre_tipo_curso)) = ''
        BEGIN
            PRINT 'Error: El nombre_tipo_curso es obligatorio.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar existencia
        IF NOT EXISTS (
            SELECT 1 
            FROM dbo.TIPOS_CURSOS
            WHERE id_tipo_curso = @id_tipo_curso
        )
        BEGIN
            PRINT 'Error: El registro no existe.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        UPDATE dbo.TIPOS_CURSOS
        SET nombre_tipo_curso = @nombre_tipo_curso,
            es_activo = @es_activo
        WHERE id_tipo_curso = @id_tipo_curso;

        COMMIT TRANSACTION;
        PRINT 'Registro actualizado correctamente.';

    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al actualizar.';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO
/*
Autora: Sofia Saborio
Grupo 3 - Planes de Estudio
CRUD Individual - Tabla TIPOS_CURSOS
Procedimiento: DELETE
Fecha: 21/04/2026
*/

USE SGIEDB;
GO

DROP PROCEDURE IF EXISTS dbo.sp_tipos_cursos_sofia_saborio_delete_20260421_1310;
GO

CREATE PROCEDURE dbo.sp_tipos_cursos_sofia_saborio_delete_20260421_1310
(
    @id_tipo_curso INT
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar ID obligatorio
        IF @id_tipo_curso IS NULL
        BEGIN
            PRINT 'Error: El id_tipo_curso es obligatorio.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Validar existencia
        IF NOT EXISTS (
            SELECT 1
            FROM dbo.TIPOS_CURSOS
            WHERE id_tipo_curso = @id_tipo_curso
        )
        BEGIN
            PRINT 'Error: El registro no existe.';
            ROLLBACK TRANSACTION;
            RETURN;
        END

        DELETE FROM dbo.TIPOS_CURSOS
        WHERE id_tipo_curso = @id_tipo_curso;

        COMMIT TRANSACTION;
        PRINT 'Registro eliminado correctamente.';

    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error al eliminar.';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

		-------------------------- MILTON ----------------------------------
-- CREATE--

CREATE PROCEDURE sp_insertar_tipo_carrera
    @p_id_tipo_carrera INT,
    @p_nombre_tipo_carrera VARCHAR(50),
    @p_es_activo BIT
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validación 1: ID obligatorio
        IF @p_id_tipo_carrera IS NULL
        BEGIN
            PRINT 'Error: El ID del tipo de carrera es obligatorio.';
            ROLLBACK;
            RETURN;
        END

        -- Validación 2: Nombre obligatorio
        IF @p_nombre_tipo_carrera IS NULL OR TRIM(@p_nombre_tipo_carrera) = ''
        BEGIN
            PRINT 'Error: El nombre del tipo de carrera es obligatorio.';
            ROLLBACK;
            RETURN;
        END

        -- Validación 3: Longitud del nombre (máximo 50 caracteres)
        IF LEN(@p_nombre_tipo_carrera) > 50
        BEGIN
            PRINT 'Error: El nombre del tipo de carrera no puede exceder los 50 caracteres.';
            ROLLBACK;
            RETURN;
        END

        -- Validación 4: El nombre no debe contener números
        IF @p_nombre_tipo_carrera LIKE '%[0-9]%'
        BEGIN
            PRINT 'Error: El nombre del tipo de carrera no debe contener números.';
            ROLLBACK;
            RETURN;
        END

        -- Validación 5: Estado activo obligatorio
        IF @p_es_activo IS NULL
        BEGIN
            PRINT 'Error: El estado activo es obligatorio (0 = Inactivo, 1 = Activo).';
            ROLLBACK;
            RETURN;
        END

        -- Validación 6: Estado activo debe ser 0 o 1
        IF @p_es_activo NOT IN (0, 1)
        BEGIN
            PRINT 'Error: El estado activo debe ser 0 (Inactivo) o 1 (Activo).';
            ROLLBACK;
            RETURN;
        END

        -- Validación 7: Verificar que no exista un registro con el mismo ID (PK)
        IF EXISTS (SELECT 1 FROM TIPOS_CARRERA WHERE id_tipo_carrera = @p_id_tipo_carrera)
        BEGIN
            PRINT 'Error: Ya existe un tipo de carrera con el ID ' + CAST(@p_id_tipo_carrera AS VARCHAR) + '.';
            ROLLBACK;
            RETURN;
        END

        -- Validación 8: Verificar que no exista un registro con el mismo nombre (UQ)
        IF EXISTS (SELECT 1 FROM TIPOS_CARRERA WHERE nombre_tipo_carrera = TRIM(@p_nombre_tipo_carrera))
        BEGIN
            PRINT 'Error: Ya existe un tipo de carrera con el nombre "' + @p_nombre_tipo_carrera + '".';
            ROLLBACK;
            RETURN;
        END

        -- Inserción del registro
        INSERT INTO TIPOS_CARRERA (id_tipo_carrera, nombre_tipo_carrera, es_activo)
        VALUES (@p_id_tipo_carrera, TRIM(@p_nombre_tipo_carrera), @p_es_activo);

        -- Mensaje de éxito
        PRINT '==================================================';
        PRINT 'ÉXITO: Tipo de carrera insertado correctamente.';
        PRINT 'ID: ' + CAST(@p_id_tipo_carrera AS VARCHAR);
        PRINT 'Nombre: ' + @p_nombre_tipo_carrera;
        PRINT 'Estado: ' + CASE WHEN @p_es_activo = 1 THEN 'Activo' ELSE 'Inactivo' END;
        PRINT '==================================================';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT '==================================================';
        PRINT 'ERROR EN sp_insertar_tipo_carrera:';
        PRINT ERROR_MESSAGE();
        PRINT '==================================================';
    END CATCH
END;
GO

PRINT 'Procedimiento sp_insertar_tipo_carrera creado exitosamente.';
GO

-- READ --

CREATE PROCEDURE sp_obtener_tipos_carrera
    @p_id_tipo_carrera INT = NULL
AS
BEGIN
    BEGIN TRY
        IF @p_id_tipo_carrera IS NULL
        BEGIN
            -- Obtener todos los registros          
            SELECT 
                id_tipo_carrera AS 'ID Tipo Carrera',
                nombre_tipo_carrera AS 'Nombre Tipo Carrera',
                es_activo AS 'Activo',
                CASE WHEN es_activo = 1 THEN 'Activo' ELSE 'Inactivo' END AS 'Estado'
            FROM TIPOS_CARRERA
            ORDER BY id_tipo_carrera;
            
            PRINT 'Total de registros encontrados: ' + CAST(@@ROWCOUNT AS VARCHAR);
        END
        ELSE
        BEGIN
            -- Obtener un registro específico
            SELECT 
                id_tipo_carrera AS 'ID Tipo Carrera',
                nombre_tipo_carrera AS 'Nombre Tipo Carrera',
                es_activo AS 'Activo',
                CASE WHEN es_activo = 1 THEN 'Activo' ELSE 'Inactivo' END AS 'Estado'
            FROM TIPOS_CARRERA
            WHERE id_tipo_carrera = @p_id_tipo_carrera;

            IF @@ROWCOUNT = 0
                PRINT 'No se encontró un tipo de carrera con el ID ' + CAST(@p_id_tipo_carrera AS VARCHAR) + '.';
        END
    END TRY
    BEGIN CATCH
        PRINT '==================================================';
        PRINT 'ERROR EN sp_obtener_tipos_carrera:';
        PRINT ERROR_MESSAGE();
        PRINT '==================================================';
    END CATCH
END;
GO

PRINT 'Procedimiento sp_obtener_tipos_carrera creado exitosamente.';
GO

-- UPDATE--
CREATE PROCEDURE sp_actualizar_tipo_carrera
    @p_id_tipo_carrera INT,
    @p_nombre_tipo_carrera VARCHAR(50),
    @p_es_activo BIT
AS
BEGIN
    DECLARE @v_nombre_anterior VARCHAR(50);
    DECLARE @v_estado_anterior BIT;
    
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validación 1: ID obligatorio
        IF @p_id_tipo_carrera IS NULL
        BEGIN
            PRINT 'Error: El ID del tipo de carrera es obligatorio.';
            ROLLBACK;
            RETURN;
        END

        -- Validación 2: Nombre obligatorio
        IF @p_nombre_tipo_carrera IS NULL OR TRIM(@p_nombre_tipo_carrera) = ''
        BEGIN
            PRINT 'Error: El nombre del tipo de carrera es obligatorio.';
            ROLLBACK;
            RETURN;
        END

        -- Validación 3: Longitud del nombre (máximo 50 caracteres)
        IF LEN(@p_nombre_tipo_carrera) > 50
        BEGIN
            PRINT 'Error: El nombre del tipo de carrera no puede exceder los 50 caracteres.';
            ROLLBACK;
            RETURN;
        END

        -- Validación 4: El nombre no debe contener números
        IF @p_nombre_tipo_carrera LIKE '%[0-9]%'
        BEGIN
            PRINT 'Error: El nombre del tipo de carrera no debe contener números.';
            ROLLBACK;
            RETURN;
        END

        -- Validación 5: Estado activo obligatorio
        IF @p_es_activo IS NULL
        BEGIN
            PRINT 'Error: El estado activo es obligatorio (0 = Inactivo, 1 = Activo).';
            ROLLBACK;
            RETURN;
        END

        -- Validación 6: Estado activo debe ser 0 o 1
        IF @p_es_activo NOT IN (0, 1)
        BEGIN
            PRINT 'Error: El estado activo debe ser 0 (Inactivo) o 1 (Activo).';
            ROLLBACK;
            RETURN;
        END

        -- Validación 7: Verificar que el registro exista
        IF NOT EXISTS (SELECT 1 FROM TIPOS_CARRERA WHERE id_tipo_carrera = @p_id_tipo_carrera)
        BEGIN
            PRINT 'Error: No existe un tipo de carrera con el ID ' + CAST(@p_id_tipo_carrera AS VARCHAR) + '.';
            ROLLBACK;
            RETURN;
        END

        -- Obtener valores anteriores para mostrar cambios
        SELECT 
            @v_nombre_anterior = nombre_tipo_carrera,
            @v_estado_anterior = es_activo
        FROM TIPOS_CARRERA
        WHERE id_tipo_carrera = @p_id_tipo_carrera;

        -- Validación 8: Verificar que no exista otro registro con el mismo nombre (UQ)
        IF EXISTS (
            SELECT 1 FROM TIPOS_CARRERA
            WHERE nombre_tipo_carrera = TRIM(@p_nombre_tipo_carrera)
            AND id_tipo_carrera != @p_id_tipo_carrera
        )
        BEGIN
            PRINT 'Error: Ya existe otro tipo de carrera con el nombre "' + @p_nombre_tipo_carrera + '".';
            ROLLBACK;
            RETURN;
        END

        -- Actualización del registro
        UPDATE TIPOS_CARRERA
        SET nombre_tipo_carrera = TRIM(@p_nombre_tipo_carrera),
            es_activo = @p_es_activo
        WHERE id_tipo_carrera = @p_id_tipo_carrera;

        -- Mensaje de éxito
        PRINT '==================================================';
        PRINT 'ÉXITO: Tipo de carrera actualizado correctamente.';
        PRINT 'ID: ' + CAST(@p_id_tipo_carrera AS VARCHAR);
        
        IF @v_nombre_anterior != @p_nombre_tipo_carrera
            PRINT 'Nombre cambiado de "' + @v_nombre_anterior + '" a "' + @p_nombre_tipo_carrera + '"';
        
        IF @v_estado_anterior != @p_es_activo
            PRINT 'Estado cambiado de ' + CASE WHEN @v_estado_anterior = 1 THEN 'Activo' ELSE 'Inactivo' END 
                + ' a ' + CASE WHEN @p_es_activo = 1 THEN 'Activo' ELSE 'Inactivo' END;
        
        PRINT '==================================================';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT '==================================================';
        PRINT 'ERROR EN sp_actualizar_tipo_carrera:';
        PRINT ERROR_MESSAGE();
        PRINT '==================================================';
    END CATCH
END;
GO

PRINT 'Procedimiento sp_actualizar_tipo_carrera creado exitosamente.';
GO

-- =====================================================
-- 5. PROCEDIMIENTO: sp_eliminar_tipo_carrera (DELETE)
-- =====================================================
CREATE PROCEDURE sp_eliminar_tipo_carrera
    @p_id_tipo_carrera INT
AS
BEGIN
    DECLARE @v_nombre_tipo VARCHAR(50);
    
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validación 1: ID obligatorio
        IF @p_id_tipo_carrera IS NULL
        BEGIN
            PRINT 'Error: El ID del tipo de carrera es obligatorio.';
            ROLLBACK;
            RETURN;
        END

        -- Obtener el nombre antes de eliminar
        SELECT @v_nombre_tipo = nombre_tipo_carrera
        FROM TIPOS_CARRERA
        WHERE id_tipo_carrera = @p_id_tipo_carrera;

        -- Validación 2: Verificar que el registro exista
        IF @v_nombre_tipo IS NULL
        BEGIN
            PRINT 'Error: No existe un tipo de carrera con el ID ' + CAST(@p_id_tipo_carrera AS VARCHAR) + '.';
            ROLLBACK;
            RETURN;
        END

        -- Validación 3: Verificar si hay dependencias (si existe la tabla CARRERAS)
        IF OBJECT_ID('CARRERAS', 'U') IS NOT NULL
        BEGIN
            IF EXISTS (SELECT 1 FROM CARRERAS WHERE id_tipo_carrera = @p_id_tipo_carrera)
            BEGIN
                PRINT '==================================================';
                PRINT 'Error: No se puede eliminar el tipo de carrera.';
                PRINT 'El tipo "' + @v_nombre_tipo + '" tiene carreras asociadas.';
                PRINT 'Primero elimine o reasigne las carreras que dependen de este tipo.';
                PRINT '==================================================';
                ROLLBACK;
                RETURN;
            END
        END

        -- Eliminación del registro
        DELETE FROM TIPOS_CARRERA
        WHERE id_tipo_carrera = @p_id_tipo_carrera;

        -- Mensaje de éxito
        PRINT '==================================================';
        PRINT 'ÉXITO: Tipo de carrera eliminado correctamente.';
        PRINT 'ID eliminado: ' + CAST(@p_id_tipo_carrera AS VARCHAR);
        PRINT 'Nombre eliminado: ' + @v_nombre_tipo;
        PRINT '==================================================';

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT '==================================================';
        PRINT 'ERROR EN sp_eliminar_tipo_carrera:';
        PRINT ERROR_MESSAGE();
        PRINT '==================================================';
    END CATCH
END;
GO

PRINT 'Procedimiento sp_eliminar_tipo_carrera creado exitosamente.';
GO

/*
   PRUEBAS DEL CRUD PARA TIPOS_CARRERA
    */


-- PRUEBA 1: INSERTAR REGISTROS--

EXEC sp_insertar_tipo_carrera 1, 'Ingeniería', 1;
EXEC sp_insertar_tipo_carrera 2, 'Licenciatura', 1;
EXEC sp_insertar_tipo_carrera 3, 'Diplomado', 0;
EXEC sp_insertar_tipo_carrera 4, 'Maestría', 1;
EXEC sp_insertar_tipo_carrera 5, 'Doctorado', 1;
GO

-- PRUEBA 2: CONSULTAR REGISTROS-- 

-- Consultar todos los registros
EXEC sp_obtener_tipos_carrera;
GO

-- Consultar un registro específico

EXEC sp_obtener_tipos_carrera 1;
GO

-- PRUEBA 3: ACTUALIZAR REGISTROS--

-- Actualizar un registro--
EXEC sp_actualizar_tipo_carrera 1, 'Ingeniería de Sistemas', 1;
EXEC sp_actualizar_tipo_carrera 3, 'Diplomado Técnico Superior', 1;
GO

-- Verificar cambios
PRINT '';
PRINT 'Verificando cambios después de actualizaciones:';
EXEC sp_obtener_tipos_carrera;
GO

-- PRUEBA 4: ELIMINAR REGISTROS

-- Eliminar un registro
EXEC sp_eliminar_tipo_carrera 3;
GO

-- Verificar que se eliminó
PRINT '';

EXEC sp_obtener_tipos_carrera;
GO


-- PRUEBA 5: VALIDACIONES - CASOS DE ERROR--


-- Error: ID duplicado
EXEC sp_insertar_tipo_carrera 1, 'Carrera Duplicada', 1;
GO

-- Error: Nombre con números

EXEC sp_insertar_tipo_carrera 10, 'Ingeniería 2024', 1;
GO

-- Error: Nombre NULL

EXEC sp_insertar_tipo_carrera 10, NULL, 1;
GO


-- Error: Actualizar ID inexistente

EXEC sp_actualizar_tipo_carrera 99, 'No Existe', 1;
GO

-- Error: Nombre duplicado al actualizar

EXEC sp_actualizar_tipo_carrera 2, 'Ingeniería de Sistemas', 1;
GO

-- Error: Eliminar ID inexistente

EXEC sp_eliminar_tipo_carrera 99;
GO

		-------------------------- EMILY ----------------------------------

        ----CREATE----
        /*
Autora: Emily Solera
Grupo 3 - Planes de Estudio
CRUD Individual - Tabla ESTADOS_PLAN_ESTUDIO
Procedimiento: CREATE
*/
CREATE PROCEDURE sp_estados_plan_estudio_emily_soler_create_20260423_1200_v3
(
    @id_estado_plan_estudio INT,
    @nombre_estado_plan_estudio VARCHAR(100)
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @id_estado_plan_estudio IS NULL
        BEGIN
            PRINT 'Error: El id_estado_plan_estudio es obligatorio.';
            ROLLBACK;
            RETURN;
        END

        IF @nombre_estado_plan_estudio IS NULL 
           OR LTRIM(RTRIM(@nombre_estado_plan_estudio)) = ''
        BEGIN
            PRINT 'Error: El nombre es obligatorio.';
            ROLLBACK;
            RETURN;
        END

        IF EXISTS (
            SELECT 1 
            FROM ESTADOS_PLAN_ESTUDIO 
            WHERE id_estado_plan_estudio = @id_estado_plan_estudio
        )
        BEGIN
            PRINT 'Error: Ya existe ese ID.';
            ROLLBACK;
            RETURN;
        END

        INSERT INTO ESTADOS_PLAN_ESTUDIO
        (
            id_estado_plan_estudio,
            nombre_estado_plan_estudio
        )
        VALUES
        (
            @id_estado_plan_estudio,
            @nombre_estado_plan_estudio
        );

        PRINT 'Registro insertado correctamente.';
        COMMIT;

    END TRY
    BEGIN CATCH
        ROLLBACK;
        PRINT 'Error al insertar: ' + ERROR_MESSAGE();
    END CATCH
END;
GO


        ----READ----
        /*
Autora: Emily Solera
Grupo 3 - Planes de Estudio
CRUD Individual - Tabla ESTADOS_PLAN_ESTUDIO
Procedimiento: READ
*/
CREATE PROCEDURE sp_estados_plan_estudio_emily_soler_read_20260423_1230
AS
BEGIN
    BEGIN TRY

        SELECT 
            id_estado_plan_estudio,
            nombre_estado_plan_estudio
        FROM ESTADOS_PLAN_ESTUDIO
        ORDER BY id_estado_plan_estudio;

    END TRY
    BEGIN CATCH
        PRINT 'Error al consultar: ' + ERROR_MESSAGE();
    END CATCH
END;
GO


        ----UPDATE----
        /*
Autora: Emily Solera
Grupo 3 - Planes de Estudio
CRUD Individual - Tabla ESTADOS_PLAN_ESTUDIO
Procedimiento: UPDATE
*/
CREATE PROCEDURE sp_estados_plan_estudio_emily_soler_update_20260423_1240
(
    @id_estado_plan_estudio INT,
    @nombre_estado_plan_estudio VARCHAR(100)
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @id_estado_plan_estudio IS NULL
        BEGIN
            PRINT 'Error: El id_estado_plan_estudio es obligatorio.';
            ROLLBACK;
            RETURN;
        END

        IF NOT EXISTS (
            SELECT 1 
            FROM ESTADOS_PLAN_ESTUDIO 
            WHERE id_estado_plan_estudio = @id_estado_plan_estudio
        )
        BEGIN
            PRINT 'Error: El registro no existe.';
            ROLLBACK;
            RETURN;
        END

        IF @nombre_estado_plan_estudio IS NULL 
           OR LTRIM(RTRIM(@nombre_estado_plan_estudio)) = ''
        BEGIN
            PRINT 'Error: El nombre es obligatorio.';
            ROLLBACK;
            RETURN;
        END

        UPDATE ESTADOS_PLAN_ESTUDIO
        SET nombre_estado_plan_estudio = @nombre_estado_plan_estudio
        WHERE id_estado_plan_estudio = @id_estado_plan_estudio;

        PRINT 'Registro actualizado correctamente.';
        COMMIT;

    END TRY
    BEGIN CATCH
        ROLLBACK;
        PRINT 'Error al actualizar: ' + ERROR_MESSAGE();
    END CATCH
END;
GO


        ----DELETE----
        /*
Autora: Emily Solera
Grupo 3 - Planes de Estudio
CRUD Individual - Tabla ESTADOS_PLAN_ESTUDIO
Procedimiento: DELETE
*/
CREATE PROCEDURE sp_estados_plan_estudio_emily_soler_delete_20260423_1250
(
    @id_estado_plan_estudio INT
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @id_estado_plan_estudio IS NULL
        BEGIN
            PRINT 'Error: El id_estado_plan_estudio es obligatorio.';
            ROLLBACK;
            RETURN;
        END

        IF NOT EXISTS (
            SELECT 1 
            FROM ESTADOS_PLAN_ESTUDIO 
            WHERE id_estado_plan_estudio = @id_estado_plan_estudio
        )
        BEGIN
            PRINT 'Error: El registro no existe.';
            ROLLBACK;
            RETURN;
        END

        DELETE FROM ESTADOS_PLAN_ESTUDIO
        WHERE id_estado_plan_estudio = @id_estado_plan_estudio;

        PRINT 'Registro eliminado correctamente.';
        COMMIT;

    END TRY
    BEGIN CATCH
        ROLLBACK;
        PRINT 'Error al eliminar: ' + ERROR_MESSAGE();
    END CATCH
END;
GO
-- =====================================================
-- PRUEBAS CRUD - ESTADOS_PLAN_ESTUDIO (EMILY)
-- =====================================================

PRINT '==============================================';
PRINT 'PRUEBA 1: INSERTAR REGISTROS';
PRINT '==============================================';

EXEC sp_estados_plan_estudio_emily_soler_create_20260423_1200_v3 1, 'Activo';
EXEC sp_estados_plan_estudio_emily_soler_create_20260423_1200_v3 2, 'Inactivo';
GO

PRINT '';
PRINT '==============================================';
PRINT 'PRUEBA 2: CONSULTAR REGISTROS';
PRINT '==============================================';

EXEC sp_estados_plan_estudio_emily_soler_read_20260423_1230;
GO

PRINT '';
PRINT '==============================================';
PRINT 'PRUEBA 3: ACTUALIZAR REGISTROS';
PRINT '==============================================';

EXEC sp_estados_plan_estudio_emily_soler_update_20260423_1240 1, 'Activo Modificado';
GO

PRINT '';
PRINT 'Verificando cambios:';
EXEC sp_estados_plan_estudio_emily_soler_read_20260423_1230;
GO

PRINT '';
PRINT '==============================================';
PRINT 'PRUEBA 4: ELIMINAR REGISTROS';
PRINT '==============================================';

EXEC sp_estados_plan_estudio_emily_soler_delete_20260423_1250 2;
GO

PRINT '';
PRINT 'Verificando eliminación:';
EXEC sp_estados_plan_estudio_emily_soler_read_20260423_1230;
GO

PRINT '';
PRINT '==============================================';
PRINT 'PRUEBA 5: VALIDACIONES (ERRORES)';
PRINT '==============================================';

-- ID NULL
PRINT 'Caso 1: ID NULL';
EXEC sp_estados_plan_estudio_emily_soler_create_20260423_1200_v3 NULL, 'Activo';
GO

-- Nombre vacío
PRINT '';
PRINT 'Caso 2: Nombre vacío';
EXEC sp_estados_plan_estudio_emily_soler_create_20260423_1200_v3 10, '';
GO

-- ID duplicado
PRINT '';
PRINT 'Caso 3: ID duplicado';
EXEC sp_estados_plan_estudio_emily_soler_create_20260423_1200_v3 1, 'Duplicado';
GO

-- UPDATE con ID inexistente
PRINT '';
PRINT 'Caso 4: Update ID inexistente';
EXEC sp_estados_plan_estudio_emily_soler_update_20260423_1240 99, 'No existe';
GO

-- DELETE con ID inexistente
PRINT '';
PRINT 'Caso 5: Delete ID inexistente';
EXEC sp_estados_plan_estudio_emily_soler_delete_20260423_1250 99;
GO

-- DELETE con ID NULL
PRINT '';
PRINT 'Caso 6: Delete ID NULL';
EXEC sp_estados_plan_estudio_emily_soler_delete_20260423_1250 NULL;
GO
