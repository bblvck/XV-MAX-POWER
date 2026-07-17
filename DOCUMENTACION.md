# Javi Calorías — Documentación del prototipo local

## 1. Descripción

Se ha creado un prototipo web local para convertir el Excel de seguimiento calórico en una aplicación usable desde ordenador y móvil.

El prototipo funciona sin servidor ni base de datos. Los cambios del usuario se guardan en el navegador mediante `localStorage`.

## 2. Archivos creados

### `index.html`

Contiene la estructura principal de la aplicación:

- Resumen diario.
- Registro de comidas.
- Biblioteca de alimentos.
- Historial y progreso.
- Ajustes personales.
- Navegación inferior optimizada para móvil.

### `styles.css`

Contiene el diseño visual responsive:

- Adaptación a pantallas móviles.
- Tarjetas de resumen.
- Navegación inferior fija.
- Colores diferenciados para proteínas, grasas e hidratos.
- Gráficas sencillas mediante CSS.
- Tipografías, espaciados, botones y estados visuales.

### `app.js`

Contiene toda la lógica de la aplicación:

- Datos iniciales basados en el Excel.
- Cálculo de objetivos calóricos.
- Registro editable por día y comida.
- Cálculo de totales y macros.
- Persistencia mediante `localStorage`.
- Gestión de alimentos personalizados.
- Historial semanal.
- Navegación entre secciones.
- Mensajes de confirmación.

### `README.md`

Incluye una guía breve de uso y la dirección de las siguientes fases del proyecto.

### `Copia de Volumen.xlsx`

Es el Excel original utilizado como referencia para el análisis y para precargar los datos del prototipo.

## 3. Análisis realizado del Excel

El libro contiene cinco hojas:

- `Semana 1`
- `Semana 2`
- `Semana 3`
- `Semana 4`
- `Copia de Semana 4`

Cada semana organiza los datos en varias zonas:

### Calorías

Se registran por día y por comida:

- Desayuno.
- Comida.
- Cena.
- Snacks.
- Batido o merienda.

### Macronutrientes

Se registran:

- Proteínas.
- Grasas.
- Hidratos de carbono.

### Peso

Cada semana contiene:

- Peso inicial.
- Peso final.
- Subida o bajada de peso.

### Objetivos y gasto

El Excel calcula o muestra:

- TMB.
- Gasto diario.
- Total del día.
- Superávit.
- Kcal objetivo.
- Límites mínimos y máximos de macros.

## 4. Datos incorporados al prototipo

Se han trasladado al prototipo las cuatro semanas disponibles con sus datos principales de:

- Calorías diarias.
- Objetivos diarios.
- Proteínas.
- Grasas.
- Hidratos.
- Peso inicial y final cuando están disponibles.
- Distribución de calorías por comida.

La pestaña `Copia de Semana 4` se ha interpretado como una plantilla vacía, por lo que no se ha usado como semana histórica adicional.

## 5. Funciones implementadas

### Resumen

La pantalla principal muestra:

- Calorías consumidas.
- Objetivo calórico.
- Proteínas del día.
- Diferencia respecto al objetivo.
- Porcentaje visual de cumplimiento.
- Desglose de comidas.
- Peso reciente.

### Registro diario

Permite:

- Cambiar de fecha.
- Editar nombre de la comida.
- Editar calorías.
- Editar proteínas.
- Añadir una nueva comida, como una merienda.
- Consultar barras de progreso de macros.

### Biblioteca de alimentos

Incluye un catálogo inicial de ejemplo con:

- Avena.
- Pechuga de pollo.
- Arroz blanco cocido.
- Huevos.
- Yogur griego.
- Plátano.

También permite añadir alimentos personalizados y buscar por nombre o marca.

El catálogo inicial es provisional porque el Excel no contiene nombres de productos ni fichas nutricionales detalladas.

### Historial

Incluye:

- Selector de semana.
- Peso inicial.
- Peso final.
- Cambio de peso.
- Gráfica de calorías consumidas frente a objetivo.
- Media semanal de proteínas, grasas e hidratos.

### Ajustes

Permite editar:

- Peso actual.
- Altura.
- Edad.
- Factor de actividad.
- Extra calórico para volumen.

El objetivo se recalcula a partir de estos datos.

## 6. Cálculo del objetivo calórico

El prototipo utiliza una estimación basada en la fórmula de Mifflin-St Jeor para hombre:

```text
TMB = 10 × peso + 6,25 × altura − 5 × edad + 5
```

Después se aplica el factor de actividad y se suma el extra configurado para volumen:

```text
Objetivo = TMB × actividad + extra de volumen
```

Los valores son editables desde Ajustes.

## 7. Correcciones y mejoras respecto al Excel

El prototipo evita algunos problemas detectados en el archivo original:

- No calcula una pérdida de peso falsa cuando el peso final está vacío.
- No depende de celdas concretas para mostrar el resumen.
- Permite editar los datos desde el móvil.
- Centraliza los objetivos personales.
- Permite añadir comidas y alimentos sin duplicar hojas.
- Muestra los datos con una interfaz más clara y visual.

## 8. Cómo utilizarlo

1. Abrir la carpeta `JaviCalorias`.
2. Hacer doble clic en `index.html`.
3. Usar la navegación inferior para cambiar de sección.
4. Editar los valores del día desde `Registrar`.
5. Añadir alimentos desde `Alimentos`.
6. Configurar los objetivos desde `Ajustes`.

Los cambios quedan guardados automáticamente en el navegador utilizado.

Si se borran los datos del sitio del navegador, se perderán los cambios personalizados y volverán a cargarse los datos iniciales.

## 9. Estado actual

El proyecto se encuentra en fase de prototipo local.

Está preparado para probar:

- Navegación.
- Diseño móvil.
- Cálculos básicos.
- Edición diaria.
- Persistencia local.
- Catálogo inicial.

La verificación realizada incluye:

- Comprobación de sintaxis de `app.js`.
- Comprobación de carga HTTP de la página local.
- Revisión de enlaces internos entre HTML, CSS y JavaScript.

## 10. Mejoras recomendadas para la siguiente fase

### Catálogo real de productos

Crear una base de datos con:

- Nombre del producto.
- Marca.
- Ración.
- Calorías.
- Proteínas.
- Grasas.
- Hidratos.
- Fibra.
- Imagen opcional.

### Comidas y recetas

Permitir guardar recetas completas y añadirlas a un día con un toque.

### Importación del Excel

Crear una pantalla para importar nuevas semanas desde el archivo Excel y conservar el historial.

### Peso y medidas

Añadir:

- Registro de peso diario.
- Media móvil semanal.
- Medidas corporales.
- Gráfica de tendencia.

### Sincronización

Cuando `@Sites` esté disponible, trasladar los datos a un backend o sistema de almacenamiento sincronizado para consultar la aplicación desde varios dispositivos.

### Cuenta de usuario

Añadir inicio de sesión para que los datos no dependan de un único navegador.

### Exportación

Permitir exportar los registros actualizados a Excel o CSV.

## 11. Limitaciones actuales

- El catálogo de alimentos todavía es de ejemplo.
- No existe sincronización entre dispositivos.
- La información se guarda únicamente en el navegador.
- Las gráficas son visualizaciones sencillas creadas con HTML y CSS.
- El prototipo no sustituye asesoramiento médico o nutricional profesional.
- La aplicación todavía no está publicada como sitio accesible desde Internet.

## 12. Próximo paso recomendado

El siguiente paso sería construir el catálogo real de productos que utiliza habitualmente Javi. Para ello habría que recopilar los nombres, marcas y valores nutricionales de sus alimentos más frecuentes, o incorporar una lista de productos al Excel actual.
