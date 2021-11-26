CREATE TABLE `tAgent` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `nombre` varchar(500) DEFAULT NULL,
  `tipo` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`ID`),
  KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=latin1;


CREATE TABLE `tAssets` (
  `id` int(11) DEFAULT NULL,
  `Version` decimal(10,0) DEFAULT NULL,
  `idObra` int(11) DEFAULT NULL,
  `nombre` varchar(50) DEFAULT NULL,
  `idVerizon` varchar(50) DEFAULT NULL,
  `tipo` int(11) DEFAULT NULL,
  `duracion` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `tConsumoHoraPais` (
  `Fecha` date NOT NULL,
  `HORA` int(11) NOT NULL,
  `Pais` char(3) NOT NULL,
  `bloques` int(11) DEFAULT '0',
  `Milisegundos` int(11) DEFAULT '0',
  PRIMARY KEY (`Fecha`,`HORA`,`Pais`),
  KEY `index2` (`Fecha`,`HORA`,`Pais`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `tConsumoObraPais` (
  `idVerizon` char(32) NOT NULL,
  `Pais` char(3) NOT NULL,
  `Milisegundos` int(11) DEFAULT NULL,
  `fecha` date NOT NULL,
  PRIMARY KEY (`idVerizon`,`Pais`,`fecha`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;


CREATE TABLE `tPlays` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `idSession` char(32) NOT NULL,
  `Inicio` datetime NOT NULL,
  `idUsuario` int(11) NOT NULL,
  `idPais` char(3) NOT NULL,
  `idVerizon` char(32) NOT NULL,
  `ip` char(40) NOT NULL,
  `idAgente` int(11) DEFAULT NULL,
  `retransmits` int(11) DEFAULT '0',
  `blocks` int(11) DEFAULT '0',
  `A` int(11) DEFAULT '0',
  `B` int(11) DEFAULT '0',
  `C` int(11) DEFAULT '0',
  `D` int(11) DEFAULT '0',
  `E` int(11) DEFAULT '0',
  `F` int(11) DEFAULT '0',
  `G` int(11) DEFAULT '0',
  `tamDistribucion` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idxSessionVerizon` (`idSession`,`idVerizon`)
) ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=latin1;


CREATE TABLE `tPlaysDistribucion` (
  `id` int(11) NOT NULL,
  `Distribucion` varchar(890) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

