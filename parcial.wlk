//la tranquilidad de cada edificio es distinta, por eso no es necesario que este en la superclase, tranquilidad tiene que ser un metodo
//tener mas cuidado cuando los metodos son cantidad,escribir bien los nombres de lo metodos
class Imperio {

	var cantDinero
	var ciudades = []

	method estaEndeudado() = cantDinero < 0

//2
	method esMasPoderosoQue(otroImperio) = self.cantidadDeCiudadesGrosas() > otroImperio.cantidadDeCiudadesGrosas()

// tenemos que saber quienes son las ciudades grosas, por eso las filtramos, porque no todas las ciudades son grosas
	method cantidadDeCiudadesGrosas() = ciudades.filter({ ciudad => ciudad.esGrosa() }).size()

//3.b
	method construirEnCiudad(ciudad, edificio) {
		// se fija si tiene plata para construir el edificio
		if (!(cantDinero >= ciudad.costoConstruccion(edificio) && edificio.puedeConstruirse(ciudad))) {
			self.error("No se puede construir edificio")
			
		} 
		ciudad.agregarEdificio(edificio)
			cantDinero -= ciudad.costoConstruccion(edificio)// es el edificio el que sabe si puede construirse en la ciudad
	}

	method evolucionar() {
		ciudades.forEach({ ciudad => ciudad.aumentarPoblacion()})
		cantDinero -= ciudades.sum({ ciudad => ciudad.costoMantenimientoTotal() })
		cantDinero += ciudades.sum({ ciudad => ciudad.ganacia() })
		ciudades.forEach({ ciudad => ciudad.agregarUnidadesMilitares()})
	}

}

class Ciudad {

	var property porcentaje
	var habitantes // cantidad
	var property edificios = []
	var property unidadesMilitares
	var imperioQuePertenece
	var property tipoImpositivo

// 1 
	method esFeliz() = !imperioQuePertenece.estaEndeudado() && self.tranquilidadTotal() > self.disconformidad()

//es polimorfico
	method tranquilidadTotal() {
		return edificios.sum({ edificio => edificio.tranquilidad() })
	}

	method disconformidad() = habitantes * 1 / 10000 + self.extraPorUnidadesMilitares()

	method extraPorUnidadesMilitares() = self.unidadesMilitares().max(0).min(30)

	method costoConstruccion(edificio) { // el costo final
		return tipoImpositivo.costoSistema(self, edificio)
	}

	method esGrosa() = habitantes > 1000000 || self.edificios().size() > 20 && self.unidadesMilitares() > 10

	method agregarEdificio(nuevoEdificio) {
		edificios.add(nuevoEdificio)
	}

	// 4.a
	method aumentarPoblacion() {
		if (self.esFeliz()) {
			habitantes += habitantes * 0.02
		}
	}

	method costoMantenimientoTotal() {
		return edificios.sum({ edificio => edificio.costoMantenimiento(self) })
	}

	method ganacia() {
		return edificios.sum({ edificio => edificio.generaDinero() })
	}

	method agregarUnidadesMilitares() {
		unidadesMilitares += edificios.sum({ edificio => edificio.agregarUnidades(self) })
	}

}

class Edificio {

	var costo // es distinto para cada edificio

	method costoMantenimiento(ciudad) {
		return ciudad.costoConstruccion(self) * 0.01 // se tiene que hacer sobre el costo total
	}

	method puedeConstruirse(ciudad) = true

	method generaDinero() = 0

	method agregarUnidades(ciudad) = 0 

}

class Economico inherits Edificio {

	var property generaDinero

	method tranquilidad() = 3

}

class Cultural inherits Edificio {

	var property cultura // cantidad

	method tranquilidad() = cultura.size() * 3

}

class Militar inherits Edificio {

	var incrementarUnidades

	override method puedeConstruirse(ciudad) = ciudad.habitantes().size() > 20000

	override method agregarUnidades(ciudad) = incrementarUnidades

	method tranquilidad() = 0

}

object citadino {

	method costoSistema(ciudad, edificio) = edificio.costo() + ciudad.habitantes().size() * (0.05 / 25000)

}

object incentivoCultural {

	method costoSistema(ciudad, edificio) = edificio.costo() - edificio.cultura()

}

object apaciguador {

	method costoSistema(ciudad, edificio) = edificio.costo() + self.costoSegunSiLaCiudadEsFelizONo(ciudad, edificio)

	method costoSegunSiLaCiudadEsFelizONo(ciudad, edificio) {
		if (ciudad.esFeliz()) {
			return edificio.costo() * ciudad.porcentaje() / 100
		} else {
			return -( edificio.tranquilidad())
		}
	}

}
