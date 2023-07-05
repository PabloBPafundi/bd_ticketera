-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `bd_ticketera`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AgregarUsuario` (IN `p_nro_legajo` VARCHAR(45), IN `p_nro_dni` VARCHAR(8), IN `p_nombre_area` VARCHAR(45), IN `p_fk_id_tipo_usuario` INT, IN `p_nombre` VARCHAR(45), IN `p_apellido` VARCHAR(45), IN `p_fk_id_superior` INT, IN `p_mail_laboral` VARCHAR(45), IN `p_nombre_campaña` VARCHAR(45), IN `p_nro_telefono` VARCHAR(15), IN `p_direccion_domicilio` VARCHAR(45))   BEGIN
    INSERT INTO usuario
    (nro_legajo, nro_dni, nombre_area, fk_id_tipo_usuario, nombre, apellido, fk_id_superior, mail_laboral, nombre_campaña, nro_telefono, direccion_domicilio)
    VALUES
    (p_nro_legajo, p_nro_dni, p_nombre_area, p_fk_id_tipo_usuario, p_nombre, p_apellido, p_fk_id_superior, p_mail_laboral, p_nombre_campaña, p_nro_telefono, p_direccion_domicilio);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `EditarUsuario` (IN `p_id_usuario` INT, IN `p_nro_legajo` VARCHAR(45), IN `p_nro_dni` VARCHAR(8), IN `p_nombre_area` VARCHAR(45), IN `p_fk_id_tipo_usuario` INT, IN `p_nombre` VARCHAR(45), IN `p_apellido` VARCHAR(45), IN `p_fk_id_superior` INT, IN `p_mail_laboral` VARCHAR(45), IN `p_nombre_campaña` VARCHAR(45), IN `p_nro_telefono` VARCHAR(15), IN `p_direccion_domicilio` VARCHAR(45))   BEGIN
    UPDATE usuario
    SET nro_legajo = p_nro_legajo,
        nro_dni = p_nro_dni,
        nombre_area = p_nombre_area,
        fk_id_tipo_usuario = p_fk_id_tipo_usuario,
        nombre = p_nombre,
        apellido = p_apellido,
        fk_id_superior = p_fk_id_superior, 
        mail_laboral = p_mail_laboral,
        nombre_campaña = p_nombre_campaña,
        nro_telefono = p_nro_telefono,
        direccion_domicilio = p_direccion_domicilio
    WHERE id_usuario = p_id_usuario;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `EstablecerDisponibilidadInsumo` (IN `insumoId` INT)   BEGIN
  UPDATE insumo SET is_available = 1 WHERE id_insumo = insumoId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `GenerarInformeControlStock` ()   BEGIN
    SELECT c.id_control_stock_insumo, c.fechaHora, u.nombre, i.nombre_insumo, c.accion
    FROM control_stock_insumo c
    INNER JOIN usuario u ON c.fk_id_usuario = u.id_usuario
    INNER JOIN insumo i ON c.fk_id_insumo = i.id_insumo;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `MarcarNoDisponibleInsumo` (IN `insumoId` INT)   BEGIN
  UPDATE insumo SET is_available = 0 WHERE id_insumo = insumoId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `MostrarComputadorasArmadas` ()   BEGIN
    SELECT c.id_computadora_armada, c.nombre_equipo, c.sistema_operativo, i.id_insumo, i.nombre_insumo, i.estado_insumo, i.capacidad, i.precio, i.modelo, i.fabricante, i.fecha_adquisicion
    FROM computadora_armada c
    INNER JOIN insumo i ON c.id_computadora_armada = i.fk_id_computadora_armada
    INNER JOIN categoria cat ON c.fk_id_categoria = cat.id_categoria
    WHERE cat.nombre_categoria = 'PC Armada' AND c.is_visible = 1;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `obtener_tickets_abiertos` ()   BEGIN
 
  CREATE TEMPORARY TABLE temp_tickets_abiertos AS
  SELECT t.id_ticket, t.descripcion_tecnico, t.fechaHora_inicio, t.fk_id_criticidad, t.fk_id_pedido, t.estado, t.fk_id_tecnico
  FROM ticket t
  WHERE t.estado = 'Abierto';


  SELECT *
  FROM temp_tickets_abiertos;

 
  DROP TEMPORARY TABLE IF EXISTS temp_tickets_abiertos;
END$$

--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `CalcularTiempoPromedio` () RETURNS TIME  BEGIN
  DECLARE tiempoPromedio TIME;

  SELECT SEC_TO_TIME(AVG(TIMESTAMPDIFF(SECOND, fechaHora_inicio, fechaHora_cierre))) INTO tiempoPromedio
  FROM ticket
  WHERE fechaHora_cierre IS NOT NULL;

  RETURN tiempoPromedio;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `ContarPedidosUsuario` (`fecha` DATE, `dni` VARCHAR(8)) RETURNS INT(11)  BEGIN
  DECLARE contador INT;

  SELECT COUNT(*) INTO contador
  FROM solicitud_insumo si
  INNER JOIN ticket t ON si.fk_id_ticket = t.id_ticket
  INNER JOIN pedido p ON t.fk_id_pedido = p.id_solicitante_asisetencia
  INNER JOIN usuario u ON p.fk_id_usuario = u.id_usuario
  WHERE DATE(p.fecha_hora) = fecha
    AND u.nro_dni = dni;

  RETURN contador;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categoria`
--

CREATE TABLE `categoria` (
  `id_categoria` int(11) NOT NULL,
  `nombre_categoria` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `computadora_armada`
--

CREATE TABLE `computadora_armada` (
  `id_computadora_armada` int(11) NOT NULL,
  `fk_id_categoria` int(11) NOT NULL,
  `nombre_equipo` varchar(45) DEFAULT NULL,
  `sistema_operativo` varchar(45) DEFAULT NULL,
  `is_visible` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `control_stock_insumo`
--

CREATE TABLE `control_stock_insumo` (
  `id_control_stock_insumo` int(11) NOT NULL,
  `fechaHora` timestamp NOT NULL DEFAULT current_timestamp(),
  `fk_id_usuario` int(11) DEFAULT NULL,
  `fk_id_insumo` int(11) DEFAULT NULL,
  `accion` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `criticidad`
--

CREATE TABLE `criticidad` (
  `id_criticidad` int(11) NOT NULL,
  `prioridad` varchar(45) NOT NULL,
  `detalle` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `datos_pc`
--

CREATE TABLE `datos_pc` (
  `id_datos_pc` int(11) NOT NULL,
  `nombre_equipo` varchar(45) NOT NULL,
  `procesador` varchar(45) NOT NULL,
  `memoria_ram` varchar(45) NOT NULL,
  `fk_id_usuario` int(11) NOT NULL,
  `fecha_alta` date NOT NULL,
  `sistemaOperativo` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `insumo`
--

CREATE TABLE `insumo` (
  `id_insumo` int(11) NOT NULL,
  `nombre_insumo` varchar(45) NOT NULL,
  `estado_insumo` varchar(45) NOT NULL,
  `capacidad` varchar(45) DEFAULT NULL,
  `id_dispositivo` varchar(45) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `fk_id_categoria` int(11) NOT NULL,
  `fk_id_computadora_armada` int(11) DEFAULT NULL,
  `modelo` varchar(45) NOT NULL,
  `fabricante` varchar(45) NOT NULL,
  `fecha_adquisicion` date NOT NULL,
  `is_visible` tinyint(1) NOT NULL DEFAULT 1,
  `is_available` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Disparadores `insumo`
--
DELIMITER $$
CREATE TRIGGER `trigger_actualizar_control_stock` BEFORE UPDATE ON `insumo` FOR EACH ROW BEGIN
    DECLARE user_id INT;

    SET @accion = '';

    SELECT id_usuario INTO user_id FROM usuario WHERE id_usuario = CURRENT_USER();

    IF NOT NEW.is_visible THEN
        SET @accion = 'Eliminado';
    ELSEIF NEW.is_available = 0 THEN
        SET @accion = 'Retiro';
    ELSE
        SET @accion = 'Devolución';
    END IF;

    IF @accion != '' THEN
        INSERT INTO control_stock_insumo (fk_id_usuario, fk_id_insumo, accion)
        VALUES (user_id, NEW.id_insumo, @accion);
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trigger_actualizar_estado` AFTER UPDATE ON `insumo` FOR EACH ROW BEGIN
    IF NEW.is_available <> OLD.is_available OR NEW.is_visible <> OLD.is_visible THEN
        UPDATE computadora_armada AS ca
        INNER JOIN insumo AS i ON ca.id_computadora_armada = i.fk_id_computadora_armada
        SET ca.is_visible = 0
        WHERE i.fk_id_computadora_armada = NEW.fk_id_computadora_armada;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pedido`
--

CREATE TABLE `pedido` (
  `id_solicitante_asisetencia` int(11) NOT NULL,
  `tipo_incoveniente` varchar(45) NOT NULL,
  `fecha_hora` timestamp NOT NULL DEFAULT current_timestamp(),
  `fk_id_usuario` int(11) NOT NULL,
  `nombre_equipo` varchar(45) NOT NULL,
  `comentario` varchar(140) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `solicitud_computadora`
--

CREATE TABLE `solicitud_computadora` (
  `id_solicitud_computadora` int(11) NOT NULL,
  `fk_id_ticket` int(11) NOT NULL,
  `fk_id_computadora_armada` int(11) DEFAULT NULL,
  `estado_solicitud` varchar(45) NOT NULL,
  `descripcion_pedido` varchar(45) NOT NULL,
  `cantidad_solicitada` int(11) NOT NULL,
  `fecha_solicitud` date DEFAULT NULL,
  `fecha_aprobación` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `solicitud_insumo`
--

CREATE TABLE `solicitud_insumo` (
  `id_solicitud_insumo` int(11) NOT NULL,
  `fk_id_ticket` int(11) NOT NULL,
  `fk_id_insumo` int(11) DEFAULT NULL,
  `nombre_herramienta` varchar(45) NOT NULL,
  `estado_solicitud` varchar(45) NOT NULL,
  `descripcion_pedido` varchar(45) NOT NULL,
  `cantidad_solicitada` int(11) NOT NULL,
  `fecha_solicitud` date DEFAULT NULL,
  `fecha_aprobación` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ticket`
--

CREATE TABLE `ticket` (
  `id_ticket` int(11) NOT NULL,
  `descripcion_tecnico` varchar(45) DEFAULT NULL,
  `fechaHora_inicio` datetime NOT NULL,
  `fechaHora_cierre` datetime NOT NULL,
  `fk_id_criticidad` int(11) NOT NULL,
  `fk_id_pedido` int(11) NOT NULL,
  `estado` varchar(45) NOT NULL,
  `fk_id_tecnico` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_usuario`
--

CREATE TABLE `tipo_usuario` (
  `id_tipo_usuario` int(11) NOT NULL,
  `nombre_rol` varchar(45) NOT NULL,
  `descripcion_rol` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id_usuario` int(11) NOT NULL,
  `nro_legajo` varchar(45) NOT NULL,
  `nro_dni` varchar(8) NOT NULL,
  `nombre_area` varchar(45) NOT NULL,
  `fk_id_tipo_usuario` int(11) NOT NULL,
  `nombre` varchar(45) NOT NULL,
  `apellido` varchar(45) NOT NULL,
  `fk_id_superior` int(11) DEFAULT NULL,
  `mail_laboral` varchar(45) NOT NULL,
  `nombre_campaña` varchar(45) NOT NULL,
  `nro_telefono` varchar(15) NOT NULL,
  `direccion_domicilio` varchar(45) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_control_stock_insumo`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_control_stock_insumo` (
`id_control_stock_insumo` int(11)
,`fechaHora` timestamp
,`fk_id_usuario` int(11)
,`fk_id_insumo` int(11)
,`accion` varchar(20)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_insumo`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_insumo` (
`id_insumo` int(11)
,`nombre_insumo` varchar(45)
,`estado_insumo` varchar(45)
,`capacidad` varchar(45)
,`id_dispositivo` varchar(45)
,`precio` decimal(10,2)
,`fk_id_categoria` int(11)
,`fk_id_computadora_armada` int(11)
,`modelo` varchar(45)
,`fabricante` varchar(45)
,`fecha_adquisicion` date
,`is_visible` tinyint(1)
,`is_available` tinyint(1)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_usuario`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_usuario` (
`id_usuario` int(11)
,`nro_legajo` varchar(45)
,`nro_dni` varchar(8)
,`nombre_area` varchar(45)
,`fk_id_tipo_usuario` int(11)
,`nombre` varchar(45)
,`apellido` varchar(45)
,`fk_id_superior` int(11)
,`mail_laboral` varchar(45)
,`nombre_campaña` varchar(45)
,`nro_telefono` varchar(15)
,`direccion_domicilio` varchar(45)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_control_stock_insumo`
--
DROP TABLE IF EXISTS `vista_control_stock_insumo`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_control_stock_insumo`  AS SELECT `control_stock_insumo`.`id_control_stock_insumo` AS `id_control_stock_insumo`, `control_stock_insumo`.`fechaHora` AS `fechaHora`, `control_stock_insumo`.`fk_id_usuario` AS `fk_id_usuario`, `control_stock_insumo`.`fk_id_insumo` AS `fk_id_insumo`, `control_stock_insumo`.`accion` AS `accion` FROM `control_stock_insumo` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_insumo`
--
DROP TABLE IF EXISTS `vista_insumo`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_insumo`  AS SELECT `insumo`.`id_insumo` AS `id_insumo`, `insumo`.`nombre_insumo` AS `nombre_insumo`, `insumo`.`estado_insumo` AS `estado_insumo`, `insumo`.`capacidad` AS `capacidad`, `insumo`.`id_dispositivo` AS `id_dispositivo`, `insumo`.`precio` AS `precio`, `insumo`.`fk_id_categoria` AS `fk_id_categoria`, `insumo`.`fk_id_computadora_armada` AS `fk_id_computadora_armada`, `insumo`.`modelo` AS `modelo`, `insumo`.`fabricante` AS `fabricante`, `insumo`.`fecha_adquisicion` AS `fecha_adquisicion`, `insumo`.`is_visible` AS `is_visible`, `insumo`.`is_available` AS `is_available` FROM `insumo` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_usuario`
--
DROP TABLE IF EXISTS `vista_usuario`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_usuario`  AS SELECT `usuario`.`id_usuario` AS `id_usuario`, `usuario`.`nro_legajo` AS `nro_legajo`, `usuario`.`nro_dni` AS `nro_dni`, `usuario`.`nombre_area` AS `nombre_area`, `usuario`.`fk_id_tipo_usuario` AS `fk_id_tipo_usuario`, `usuario`.`nombre` AS `nombre`, `usuario`.`apellido` AS `apellido`, `usuario`.`fk_id_superior` AS `fk_id_superior`, `usuario`.`mail_laboral` AS `mail_laboral`, `usuario`.`nombre_campaña` AS `nombre_campaña`, `usuario`.`nro_telefono` AS `nro_telefono`, `usuario`.`direccion_domicilio` AS `direccion_domicilio` FROM `usuario` ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `categoria`
--
ALTER TABLE `categoria`
  ADD PRIMARY KEY (`id_categoria`);

--
-- Indices de la tabla `computadora_armada`
--
ALTER TABLE `computadora_armada`
  ADD PRIMARY KEY (`id_computadora_armada`),
  ADD KEY `fk_id_categoria` (`fk_id_categoria`);

--
-- Indices de la tabla `control_stock_insumo`
--
ALTER TABLE `control_stock_insumo`
  ADD PRIMARY KEY (`id_control_stock_insumo`),
  ADD KEY `fk_id_usuario` (`fk_id_usuario`),
  ADD KEY `fk_id_insumo` (`fk_id_insumo`);

--
-- Indices de la tabla `criticidad`
--
ALTER TABLE `criticidad`
  ADD PRIMARY KEY (`id_criticidad`);

--
-- Indices de la tabla `datos_pc`
--
ALTER TABLE `datos_pc`
  ADD PRIMARY KEY (`id_datos_pc`),
  ADD KEY `fk_id_usuario` (`fk_id_usuario`);

--
-- Indices de la tabla `insumo`
--
ALTER TABLE `insumo`
  ADD PRIMARY KEY (`id_insumo`),
  ADD KEY `fk_id_categoria` (`fk_id_categoria`),
  ADD KEY `fk_id_computadora_armada` (`fk_id_computadora_armada`);

--
-- Indices de la tabla `pedido`
--
ALTER TABLE `pedido`
  ADD PRIMARY KEY (`id_solicitante_asisetencia`),
  ADD KEY `fk_id_usuario` (`fk_id_usuario`);

--
-- Indices de la tabla `solicitud_computadora`
--
ALTER TABLE `solicitud_computadora`
  ADD PRIMARY KEY (`id_solicitud_computadora`),
  ADD KEY `fk_id_ticket` (`fk_id_ticket`),
  ADD KEY `fk_id_computadora_armada` (`fk_id_computadora_armada`);

--
-- Indices de la tabla `solicitud_insumo`
--
ALTER TABLE `solicitud_insumo`
  ADD PRIMARY KEY (`id_solicitud_insumo`),
  ADD KEY `fk_id_ticket` (`fk_id_ticket`),
  ADD KEY `fk_id_insumo` (`fk_id_insumo`);

--
-- Indices de la tabla `ticket`
--
ALTER TABLE `ticket`
  ADD PRIMARY KEY (`id_ticket`),
  ADD KEY `fk_id_criticidad` (`fk_id_criticidad`),
  ADD KEY `fk_id_pedido` (`fk_id_pedido`);

--
-- Indices de la tabla `tipo_usuario`
--
ALTER TABLE `tipo_usuario`
  ADD PRIMARY KEY (`id_tipo_usuario`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id_usuario`),
  ADD KEY `fk_id_tipo_usuario` (`fk_id_tipo_usuario`),
  ADD KEY `fk_id_superior` (`fk_id_superior`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `categoria`
--
ALTER TABLE `categoria`
  MODIFY `id_categoria` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `computadora_armada`
--
ALTER TABLE `computadora_armada`
  MODIFY `id_computadora_armada` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `control_stock_insumo`
--
ALTER TABLE `control_stock_insumo`
  MODIFY `id_control_stock_insumo` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `criticidad`
--
ALTER TABLE `criticidad`
  MODIFY `id_criticidad` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `datos_pc`
--
ALTER TABLE `datos_pc`
  MODIFY `id_datos_pc` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `insumo`
--
ALTER TABLE `insumo`
  MODIFY `id_insumo` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `pedido`
--
ALTER TABLE `pedido`
  MODIFY `id_solicitante_asisetencia` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `solicitud_computadora`
--
ALTER TABLE `solicitud_computadora`
  MODIFY `id_solicitud_computadora` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `solicitud_insumo`
--
ALTER TABLE `solicitud_insumo`
  MODIFY `id_solicitud_insumo` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `ticket`
--
ALTER TABLE `ticket`
  MODIFY `id_ticket` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tipo_usuario`
--
ALTER TABLE `tipo_usuario`
  MODIFY `id_tipo_usuario` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `computadora_armada`
--
ALTER TABLE `computadora_armada`
  ADD CONSTRAINT `computadora_armada_ibfk_1` FOREIGN KEY (`fk_id_categoria`) REFERENCES `categoria` (`id_categoria`);

--
-- Filtros para la tabla `control_stock_insumo`
--
ALTER TABLE `control_stock_insumo`
  ADD CONSTRAINT `control_stock_insumo_ibfk_1` FOREIGN KEY (`fk_id_usuario`) REFERENCES `usuario` (`id_usuario`),
  ADD CONSTRAINT `control_stock_insumo_ibfk_2` FOREIGN KEY (`fk_id_insumo`) REFERENCES `insumo` (`id_insumo`);

--
-- Filtros para la tabla `datos_pc`
--
ALTER TABLE `datos_pc`
  ADD CONSTRAINT `datos_pc_ibfk_1` FOREIGN KEY (`fk_id_usuario`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `insumo`
--
ALTER TABLE `insumo`
  ADD CONSTRAINT `insumo_ibfk_1` FOREIGN KEY (`fk_id_categoria`) REFERENCES `categoria` (`id_categoria`),
  ADD CONSTRAINT `insumo_ibfk_2` FOREIGN KEY (`fk_id_computadora_armada`) REFERENCES `computadora_armada` (`id_computadora_armada`);

--
-- Filtros para la tabla `pedido`
--
ALTER TABLE `pedido`
  ADD CONSTRAINT `pedido_ibfk_1` FOREIGN KEY (`fk_id_usuario`) REFERENCES `usuario` (`id_usuario`);

--
-- Filtros para la tabla `solicitud_computadora`
--
ALTER TABLE `solicitud_computadora`
  ADD CONSTRAINT `solicitud_computadora_ibfk_1` FOREIGN KEY (`fk_id_ticket`) REFERENCES `ticket` (`id_ticket`),
  ADD CONSTRAINT `solicitud_computadora_ibfk_2` FOREIGN KEY (`fk_id_computadora_armada`) REFERENCES `computadora_armada` (`id_computadora_armada`);

--
-- Filtros para la tabla `solicitud_insumo`
--
ALTER TABLE `solicitud_insumo`
  ADD CONSTRAINT `solicitud_insumo_ibfk_1` FOREIGN KEY (`fk_id_ticket`) REFERENCES `ticket` (`id_ticket`),
  ADD CONSTRAINT `solicitud_insumo_ibfk_2` FOREIGN KEY (`fk_id_insumo`) REFERENCES `insumo` (`id_insumo`);

--
-- Filtros para la tabla `ticket`
--
ALTER TABLE `ticket`
  ADD CONSTRAINT `ticket_ibfk_1` FOREIGN KEY (`fk_id_criticidad`) REFERENCES `criticidad` (`id_criticidad`),
  ADD CONSTRAINT `ticket_ibfk_2` FOREIGN KEY (`fk_id_pedido`) REFERENCES `pedido` (`id_solicitante_asisetencia`);

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `usuario_ibfk_1` FOREIGN KEY (`fk_id_tipo_usuario`) REFERENCES `tipo_usuario` (`id_tipo_usuario`),
  ADD CONSTRAINT `usuario_ibfk_2` FOREIGN KEY (`fk_id_superior`) REFERENCES `usuario` (`id_usuario`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
