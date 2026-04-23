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
exec sp_insertar_estado_programa_academico 1, 'activo', 1;

exec sp_obtener_estados_programas_academicos;

exec sp_obtener_estados_programas_academicos 1;

exec sp_actualizar_estado_programa_academico 1, 'inactivo', 0;

exec sp_eliminar_estado_programa_academico 1;

		-------------------------- SOFIA ----------------------------------

		-------------------------- MILTON ----------------------------------

		-------------------------- EMILY ----------------------------------