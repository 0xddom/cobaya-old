Creación de fuzzers
=====

Para crear un fuzzer hay varias formas, en función del caso de uso. Todas estas formas internamente utilizan el mismo sistema.

Aparte de la API básica que se explica a continuación, el fuzzer soporta las siguientes formas de uso:

* JSON: Un objeto JSON con la misma forma que la tabla hash de la API base

API base
------

La forma básica de crear un fuzzer es con la método `FuzzerFactory.from_hash` que recibe un objeto `Hash` y devuelve una instancia de tipo `Fuzzer`.

La tabla hash que se envia como parámetro tiene gran cantidad de opciones, que se detallan en este capítulo. El resto de formas de crear fuzzers son abstracciones sobre este sistema que premiten expresar la configuración de distintas formas.

Para crear un fuzzer se puede crear un script como el que se presenta  a continuación:

```ruby
# Carga la librería
require 'cobaya'
	
# Configura el fuzzer
hash = {...}
	
# Instancialo usando la factoría
fuzzer = Cobaya::FuzzerFactory.from_hash hash
	
# Arranca el bucle de fuzzing
fuzzer.run
```

Este modelo permite la integración con otro código Ruby, por ejemplo, un dashboard web que gestiona una serie de fuzzers y usa `cobaya` como una librería.

### El hash raíz

La tabla hash raíz es la tabla hash que se envía como parámetro. Esta tabla puede tener internamente otras tablas hash que especifican parámetros de configuración en grupos semanticos.

Los campos soportados por este parámetro son:

#### `target`

Especifíca el objetivo del fuzzing. Actualmente solo se soportan lineas de comando. Las posibles opciones son:

* Una orden que recibe su entrada por entrada estandar. El programa debe poder ser ejecutable y encontrarse en el `$PATH` en caso de no se una ruta absoluta. Por ejemplo; `/usr/bin/target` ejecutará el programa `target` sin opciones de linea de comando y enviado los datos por entrada estandar.

* Una orden que recibe su entrada por un fichero especificado como argumento de linea de comando. Este formato es igual que el anterior con la diferencia de que debe especificarse el lugar en el cual debe ir el fichero con los datos. Para marcar este lugar se escribe `{}`. El fuzzer sustituye esa marca por la ruta del fichero. Por ejemplo; `/usr/bin/target -f {}` sustituirá `{}` por un fichero temporal con los datos a probar y lo ejecutará. No se enviará nada por entrada estandar.

A continuación se muestran dos ejemplos de la funcionalidad descrita:

```ruby
# Primer formato

{
  target: '/usr/bin/target'
}

# Segundo formato

{
  target: '/usr/bin/target -f {}'
}
```

#### `corpus`

El fuzzer necesita un lugar del que tomar el corpus inicial. Esta localización se especifica con el campo `corpus`. Solo se soportan directorios del sistema de ficheros. El directorio debe de tener permiso de lectura y escritura. El fuzzer leera ficheros del directorio y, dependendiendo de la estrategia de fuzzing, puede que escriba en el directorio.

Ejemplo:

```ruby
{
  corpus: './corpus'
}
```
