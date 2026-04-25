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

		--------------------------DELETE (Sofia)-----------------------------

		--------------------------PLAN ESTUDIO DETALLE-----------------------

		--------------------------CREATE (Emily)-----------------------------

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

		--------------------------DELETE (Sofia)-----------------------------

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

/* =====================================================
   PRUEBAS DEL CRUD PARA TIPOS_CARRERA
   ===================================================== */

-- =====================================================
-- PRUEBA 1: INSERTAR REGISTROS
-- =====================================================
PRINT 'PRUEBA 1: INSERTANDO TIPOS DE CARRERA';

EXEC sp_insertar_tipo_carrera 1, 'Ingeniería', 1;
EXEC sp_insertar_tipo_carrera 2, 'Licenciatura', 1;
EXEC sp_insertar_tipo_carrera 3, 'Diplomado', 0;
EXEC sp_insertar_tipo_carrera 4, 'Maestría', 1;
EXEC sp_insertar_tipo_carrera 5, 'Doctorado', 1;
GO

-- =====================================================
-- PRUEBA 2: CONSULTAR REGISTROS
-- =====================================================
PRINT '';
PRINT 'PRUEBA 2: CONSULTANDO TIPOS DE CARRERA';
PRINT '--------------------------------------------------';

-- Consultar todos los registros
EXEC sp_obtener_tipos_carrera;
GO

-- Consultar un registro específico
PRINT '';
PRINT 'Consultando tipo de carrera con ID = 1:';
EXEC sp_obtener_tipos_carrera 1;
GO

-- =====================================================
-- PRUEBA 3: ACTUALIZAR REGISTROS
-- =====================================================
PRINT '';
PRINT 'PRUEBA 3: ACTUALIZANDO TIPOS DE CARRERA';
PRINT '--------------------------------------------------';

-- Actualizar un registro
EXEC sp_actualizar_tipo_carrera 1, 'Ingeniería de Sistemas', 1;
EXEC sp_actualizar_tipo_carrera 3, 'Diplomado Técnico Superior', 1;
GO

-- Verificar cambios
PRINT '';
PRINT 'Verificando cambios después de actualizaciones:';
EXEC sp_obtener_tipos_carrera;
GO

-- =====================================================
-- PRUEBA 4: ELIMINAR REGISTROS
-- =====================================================
PRINT '';
PRINT 'PRUEBA 4: ELIMINANDO TIPOS DE CARRERA';
PRINT '--------------------------------------------------';

-- Eliminar un registro
EXEC sp_eliminar_tipo_carrera 5;
GO

-- Verificar que se eliminó
PRINT '';
PRINT 'Verificando después de eliminación:';
EXEC sp_obtener_tipos_carrera;
GO

-- =====================================================
-- PRUEBA 5: VALIDACIONES - CASOS DE ERROR
-- =====================================================
PRINT '';
PRINT 'PRUEBA 5: PROBANDO VALIDACIONES (CASOS DE ERROR)';
PRINT '--------------------------------------------------';

-- Error: ID duplicado
PRINT 'Caso 1: Insertar con ID duplicado';
EXEC sp_insertar_tipo_carrera 1, 'Carrera Duplicada', 1;
GO

-- Error: Nombre con números
PRINT '';
PRINT 'Caso 2: Insertar nombre con números';
EXEC sp_insertar_tipo_carrera 10, 'Ingeniería 2024', 1;
GO

-- Error: Nombre NULL
PRINT '';
PRINT 'Caso 3: Insertar con nombre NULL';
EXEC sp_insertar_tipo_carrera 10, NULL, 1;
GO

-- Error: Estado inválido
PRINT '';
PRINT 'Caso 4: Insertar con estado inválido (2)';
EXEC sp_insertar_tipo_carrera 10, 'Prueba Estado', 2;
GO

-- Error: Actualizar ID inexistente
PRINT '';
PRINT 'Caso 5: Actualizar ID inexistente';
EXEC sp_actualizar_tipo_carrera 99, 'No Existe', 1;
GO

-- Error: Nombre duplicado al actualizar
PRINT '';
PRINT 'Caso 6: Actualizar con nombre duplicado';
EXEC sp_actualizar_tipo_carrera 2, 'Ingeniería de Sistemas', 1;
GO

-- Error: Eliminar ID inexistente
PRINT '';
PRINT 'Caso 7: Eliminar ID inexistente';
EXEC sp_eliminar_tipo_carrera 99;
GO

SELECT * FROM TIPOS_CARRERA ORDER BY id_tipo_carrera;
GO

		-------------------------- EMILY ----------------------------------
