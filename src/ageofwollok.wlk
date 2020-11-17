class Equipo {
	var recursos = 1000
	const property unidades = []
	const property casas = []
	const costoAldeano = 50
	const costoCasa = 100
	method recursos() = recursos
	method pasarUnAnio(){
		unidades.forEach({unidad => unidad.vivirUnAnio(self)})
	}
	method agregarRecursos(cantidad) {
		recursos += cantidad
	}
	method gastarRecursos(cantidad) {
		recursos -= cantidad
	}
	method puntosAtaque() = unidades.sum({ unidad => unidad.puntosAtaque() })
	
	method puntosDefensa() = unidades.sum({ unidad => unidad.puntosDefensa() })
	
	method esAgresivo() = (self.puntosAtaque() - self.puntosDefensa()) > 10 and self.puntosAtaque() > 20
	
	method estaBienProtegido() = self.puntosDefensa() > 15
	
	method limiteDePoblacion() = 5 + casas.filter({ casa => casa.estaTerminada()}).size() * 5
	
	method crearAldeano(tareaInicial){
		self.validarYRestarRecursos(costoAldeano)
		unidades.add(new Aldeano(tarea = tareaInicial))
	}
	
	method crearGuerrero(tipoGuerrero){
		self.validarYRestarRecursos(tipoGuerrero.costoRecursos())
		unidades.add(new Guerrero(tipoGuerrero = tipoGuerrero))
	}	
	
	method validarYRestarRecursos(costoRecursos){
		self.validadCrearUnidad(costoRecursos)
		recursos -= costoRecursos
	}
	
	method validadCrearUnidad(costoRecursos){
		self.validarLimitePoblacional()
		self.validarRecursos(costoRecursos)
	}
	
	method validarRecursos(costoRecursos){
		if (costoRecursos > recursos){
			throw new RecursosInsuficientesException(message="Recursos insuficientes")			
		}
	}
	
	method validarLimitePoblacional(){
		if (unidades.size() + 1 > self.limiteDePoblacion()){
			throw new LimitePoblacionalException(message="No se puede superar el límite poblacional")
		}
	}
	
	method construirNuevaCasa(){
		self.validarRecursos(costoCasa)
		casas.add(new Casa())
	}
	
	method tieneCasasPendientes() = casas.any({ casa => not casa.estaTerminada() })
	
	method avanzarConstruccionDeCasas(porcentaje){
		casas.forEach( { casa => casa.avanzarConstruccion(porcentaje) })
	}
	
	method reasignarUnidades(){
		unidades.forEach({unidad => unidad.reasignar()})
	}

}

class RecursosInsuficientesException inherits DomainException{} 
class LimitePoblacionalException inherits DomainException{} 

class Aldeano {
	var tarea = ocioso
	const property puntosAtaque = 1
	const property puntosDefensa = 1
	
	method tarea() = tarea
	method cambiarATarea(nuevaTarea){
		tarea = nuevaTarea
	}
	method pasarAOcioso(){
		self.cambiarATarea(ocioso)
	}
	method vivirUnAnio(equipo){
		tarea.trabajarUnAnio(equipo, self)
	}
	method reasignar(){
		tarea.reasignar(self)
	}
	
}
object ocioso { 
	method trabajarUnAnio(equipo, aldeano){}
	method reasignar(aldeano){
		aldeano.cambiarATarea(constructore)
	}
}
object granjero {
	method trabajarUnAnio(equipo, aldeano){
		equipo.agregarRecursos(10)
	}
	method reasignar(aldeano){}
}
class Leniador {
	var arbol = new Arbol()
	method arbol() = arbol
	method trabajarUnAnio(equipo, aldeano){
		if (arbol.puedeRestar(15)){
			arbol.restarMadera(15)
			equipo.agregarRecursos(15)
		}
	}
	method reasignar(aldeano){
		if (not arbol.puedeRestar(15)){
			arbol = new Arbol()
		}	
	}
}
class Arbol {
	var madera = 50
	method madera() = madera
	method puedeRestar(cantidad) = madera - cantidad >= 0
	method restarMadera(cantidad){
		madera -= cantidad
	}
}
object constructore {
	method trabajarUnAnio(equipo, aldeano){
		if (equipo.tieneCasasPendientes()){
			equipo.avanzarConstruccionDeCasas(10)			
		} else {
			aldeano.pasarAOcioso()
		}
	}
	method reasignar(aldeano){}
}

class Guerrero {
	const costoAnual = 2
	const tipoGuerrero
	method vivirUnAnio(equipo){
		equipo.gastarRecursos(costoAnual)
	}
	method puntosAtaque() = tipoGuerrero.puntosAtaque()
	method puntosDefensa() = tipoGuerrero.puntosDefensa()
	method reasignar(){}
}
object arquero {
	const property puntosDefensa = 1
	const property puntosAtaque = 3
	const property costoRecursos = 70	
}
object miliciano {
	const property puntosDefensa = 3
	const property puntosAtaque = 1
	const property costoRecursos = 100	
}
object lanzapiedras {
	const property puntosDefensa = 0
	const property puntosAtaque = 5
	const property costoRecursos = 200	
}

class Casa{
	var avanceConstruccion = 0
	method avanceConstruccion() = avanceConstruccion 
	method estaTerminada() = avanceConstruccion == 100
	method avanzarConstruccion(porcentaje){
		avanceConstruccion = [avanceConstruccion + porcentaje, 100].min()		
	}
}
class Mongol inherits Equipo {
	override method puntosAtaque() = super() + 30
}
class Persa inherits Equipo {
	override method agregarRecursos(cantidad){
		recursos += cantidad * 1.1
	}
}
class Espaniol inherits Equipo {
	override method avanzarConstruccionDeCasas(porcentaje){
		super(100) 
	}
}
class Huno inherits Equipo {
	override method validarLimitePoblacional(){}
} 
