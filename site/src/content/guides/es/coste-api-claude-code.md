---
key: api-cost
urlSlug: coste-api-claude-code
title: Cuánto costaría tu uso de Claude Code por API
seoTitle: "Cuánto costaría tu uso de Claude Code si lo pagaras por API"
description: "Cómo calcular lo que te costaría por API lo que gastas con tu suscripción de Claude Code: de dónde salen los tokens, cómo se cobra la caché y qué precio usar."
order: 4
published: 2026-11-18
updated: 2026-11-18
---

Con una suscripción pagas lo mismo cada mes, uses Claude Code mucho o poco. Saber lo que costaría ese uso por API sirve para dos cosas: ver si el plan te sale a cuenta y tener una cifra realista si algún día pasas a pagar por token, por ejemplo en un equipo o en una integración continua.

## Cómo cobra la API

La API cobra por millón de tokens, con un precio distinto para cada modelo y cada tipo de token. Los precios actuales están en la [tabla oficial de Anthropic](https://platform.claude.com/docs/en/about-claude/pricing). Lo que importa para hacer la cuenta es cómo se combinan:

| Tipo de token | Precio |
|---|---|
| Entrada | El precio base de entrada del modelo |
| Salida | El precio de salida del modelo |
| Escritura en caché, 5 minutos | 1,25 × el precio de entrada |
| Escritura en caché, 1 hora | 2 × el precio de entrada |
| Lectura de caché | 0,1 × el precio de entrada en la mayoría de modelos |

La lectura de caché tiene excepciones: en Opus 5.5 y Sonnet 5.5 cuesta 0,05 veces la entrada, y en Fable 5.2, 0,025 veces. El modo rápido tiene sus propios precios, más altos, y se suma a los multiplicadores de la caché.

La caché pesa mucho en Claude Code. Cada mensaje vuelve a enviar el contexto de la conversación y casi todo se lee de caché, así que la mayor parte de los tokens son lecturas baratas. Contar todo al precio de entrada inflaría mucho la cifra.

## De dónde salen tus tokens

Claude Code guarda cada sesión en tu Mac, en ficheros JSONL dentro de `~/.claude/projects/`. Cada respuesta del modelo lleva la fecha, el modelo usado y el recuento de tokens de cada tipo: entrada, salida, lectura de caché y escritura de caché.

Con eso, el cálculo es una suma por respuesta:

```
coste = entrada × precio_entrada
      + salida × precio_salida
      + lectura_caché × precio_lectura
      + escritura_5min × precio_entrada × 1,25
      + escritura_1h × precio_entrada × 2
```

Hay un detalle que se escapa con facilidad: la misma respuesta puede aparecer más de una vez en los registros. Hay que contarla una sola vez o la cifra sale duplicada.

## Lo que hace Orbix

[Orbix](/es/) hace esta cuenta por ti y la enseña en su panel, en la tarjeta «Si lo pagaras por API»: el coste de la sesión actual y el de los últimos 30 días a precio de lista.

- De cada línea de los registros lee solo la fecha, el modelo y el recuento de tokens. Nunca el contenido de tus conversaciones.
- Cuenta las respuestas repetidas una vez.
- Aplica el precio de cada tipo de token, la caché de 5 minutos y de 1 hora, y el modo rápido.

## Hasta dónde llega la estimación

Conviene leer la cifra con tres matices:

- Solo cuenta el uso de Claude Code en ese Mac. Lo que hagas en claude.ai, en Claude Desktop o en otro ordenador no está en esos ficheros.
- Usa los precios de lista. Si los precios cambian, la cifra cambia con ellos.
- Las respuestas de un modelo sin precio conocido no se incluyen; Orbix lo indica debajo de la cifra.

Si pagas por API con `ANTHROPIC_API_KEY`, no necesitas estimar nada: el bloque «Session» de `/usage` ya enseña el uso de tokens de la API. Para seguir los límites de una suscripción, mira [cómo ver tu uso de Claude Code](/es/guias/ver-uso-claude-code/).
