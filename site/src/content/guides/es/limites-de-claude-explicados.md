---
key: limits-explained
urlSlug: limites-de-claude-explicados
title: Los límites de 5 horas y semanal de Claude, explicados
seoTitle: "Límite de 5 horas y límite semanal de Claude: cómo funcionan"
description: "Cuándo empieza y cuándo se reinicia la sesión de 5 horas de Claude, cómo funcionan los límites semanales, qué los comparte y qué pasa cuando llegas al tope."
order: 2
published: 2026-11-18
updated: 2026-11-18
---

Si pagas Claude (Pro, Max u otro plan de pago), tienes dos límites que corren a la vez. Anthropic lo resume así en su [página de ayuda](https://support.claude.com/en/articles/11647753-usage-and-length-limits): una sesión que se reinicia cada cinco horas y unos límites semanales que se reinician una vez por semana. Cada uno funciona con su propio reloj.

## La sesión de 5 horas

La ventana empieza cuando envías tu primer mensaje y se reinicia entera cinco horas después. No va por horas fijas del día.

Un ejemplo: si tu primer mensaje de la mañana sale a las 9:40, la sesión se reinicia a las 14:40, gastes mucho o poco. Si a esa hora no estás usando Claude, la siguiente sesión empieza con el siguiente mensaje que envíes, sea a las 16:00 o a las 20:00.

Esto tiene una consecuencia práctica: si sabes que vas a tener una tarde intensa, conviene que la sesión haya empezado antes, para que el reinicio caiga en mitad del trabajo y no al final.

## Los límites semanales

Los límites semanales se reinician a una hora fija cada semana, asignada a tu cuenta. Ese día y esa hora no cambian aunque empieces a usar Claude en otro momento. Los ves en claude.ai, en **Ajustes → Uso**.

No hay un único límite semanal. En los planes Max, por ejemplo, hay uno general para todos los modelos y otro aparte para Fable. Por eso puedes tener sesión de sobra y aun así quedarte sin un modelo concreto hasta el reinicio semanal.

En las cuentas que no tienen límite de 5 horas, como Ultra, lo que manda es el semanal. Orbix lo detecta y en esas cuentas enseña el semanal en el aro de la barra de menús.

## Todo cuenta para lo mismo

El uso de claude.ai, de Claude Desktop y de Claude Code cuenta para el mismo límite. Un rato de chat en el móvil reduce lo que te queda para programar, y al revés.

La excepción son las cuentas con una clave de API (`ANTHROPIC_API_KEY`): no tienen los límites del plan, pagan por token. Y los tokens de larga duración de `claude setup-token` usan la suscripción, pero Claude Code no informa de sus límites; lo explicamos en [varias cuentas de Claude Code en un Mac](/es/guias/varias-cuentas-claude-code/).

## Cuánto da cada plan

Anthropic no publica cifras absolutas de mensajes ni de tokens por plan, y avisa de que puede ajustar los límites. Lo que sí dice es relativo: el plan Max incluye cinco veces el uso del plan Pro, tanto cada cinco horas como cada semana.

Como la cantidad depende de cómo uses Claude (un mensaje con un repositorio grande en contexto gasta mucho más que una pregunta corta), lo útil es mirar el porcentaje, que es lo que enseñan `/usage`, la página de uso y Orbix.

## Qué pasa cuando llegas al límite

Si llegas al tope de la sesión o de la semana, tienes tres salidas:

- esperar al reinicio;
- cambiar a un plan con más uso;
- seguir con créditos de uso, si los tienes activados: el trabajo continúa con ellos en lugar de pararse.

Algunas cuentas tienen además reinicios que devuelven al máximo la sesión o los límites semanales. Orbix los lee de claude.ai y enseña cuántos tienes guardados y cuándo caducan.

Si usas varias cuentas, una cuarta salida es cambiar a otra que tenga margen. Cada cuenta lleva sus propios límites.

## Cómo no llevarte sorpresas

El problema de estos límites es que Claude avisa cuando ya has llegado. Para verlos antes:

- en Claude Code, `/usage` te enseña las barras del plan;
- en claude.ai, **Ajustes → Uso** te da los días y horas de reinicio;
- [Orbix](/es/) los deja en la barra de menús del Mac, en ámbar al 70 % y en rojo al 90 %.

Los tres métodos, con sus comandos, están en [cómo ver tu uso de Claude Code](/es/guias/ver-uso-claude-code/).
