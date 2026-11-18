---
key: check-usage
urlSlug: ver-uso-claude-code
title: Cómo ver tu uso de Claude Code
seoTitle: "Cómo ver tu uso y tus límites de Claude Code: 3 formas"
description: "Tres formas de saber cuánto te queda de la sesión de 5 horas y de la semana en Claude Code: el comando /usage, la web de claude.ai y la barra de menús."
order: 1
published: 2026-11-18
updated: 2026-11-18
---

Los planes de pago de Claude tienen dos límites a la vez: una sesión que se reinicia cada cinco horas y unos límites semanales. Lo que haces en claude.ai, en Claude Desktop y en Claude Code cuenta para los mismos, así que una tarde larga en la terminal también se nota en el chat.

Hay tres sitios donde mirar cuánto te queda. Cuál te conviene depende de cuántas veces al día lo miras.

## 1. El comando /usage, dentro de Claude Code

Abre una sesión de Claude Code y escribe:

```
/usage
```

Con una suscripción (Pro, Max o Ultra) verás las barras de uso de tu plan, estadísticas de actividad y un desglose de en qué se ha ido. El bloque «Session» de arriba enseña tokens de API y está pensado para quien paga por API: con suscripción, ese uso ya va incluido en el plan.

También puedes pedirlo sin abrir una sesión interactiva:

```bash
claude -p "/usage" --no-session-persistence
```

`-p` imprime la respuesta y sale, y `--no-session-persistence` evita que esa consulta se guarde en tu historial. Es justo lo que ejecuta Orbix por debajo cada vez que se actualiza.

> Si `/usage` te enseña costes de API cuando esperabas los límites del plan, revisa si tienes `ANTHROPIC_API_KEY` definida en el entorno. Según la documentación de Claude Code, cuando la apruebas, la clave de API tiene prioridad sobre la suscripción. Ejecuta `unset ANTHROPIC_API_KEY`, abre `claude` otra vez y mira la fila «Login» de `/status`.

## 2. La página de uso de claude.ai

En el navegador, entra en **Ajustes → Uso** de claude.ai, o directamente en [claude.ai/settings/usage](https://claude.ai/settings/usage). En «Sesión actual» ves cuánto llevas de la ventana de cinco horas y debajo, los límites semanales con su día y hora de reinicio.

Desde Claude Code, el comando `/usage-credits` abre esa misma página si has entrado con una suscripción; con una clave de API no está disponible.

Para ver el detalle, esta página da más que `/usage`, a cambio de abrir el navegador con la sesión de claude.ai iniciada.

## 3. Siempre a la vista, en la barra de menús

Las dos formas anteriores tienen el mismo problema: hay que acordarse de mirar, y lo normal es acordarse cuando Claude ya te ha cortado.

[Orbix](/es/) es una app gratis para el Mac que deja el porcentaje de la sesión en la barra de menús, al lado del reloj. El aro pasa a ámbar al 70 % y a rojo al 90 %, y al pulsarlo se abre un panel con:

- la sesión de 5 horas, con lo que te queda y la hora exacta de reinicio;
- los límites semanales, el general y los de cada modelo;
- tus cuentas de Claude Code, cada una con su sesión y su semana;
- los reinicios gratis, el saldo prepago y el uso extra del mes, leídos de claude.ai.

Orbix consulta `claude /usage` en una carpeta propia y sin guardar la sesión, así que la consulta no aparece en tu historial. No pide ninguna clave: usa la sesión que ya tiene Claude Code.

## Cuál usar

| Si quieres… | Usa |
|---|---|
| Comprobarlo una vez, en mitad de una tarea | `/usage` dentro de Claude Code |
| Ver el detalle con días y horas de reinicio | claude.ai → Ajustes → Uso |
| No tener que acordarte | Orbix en la barra de menús |
| Saberlo desde un script | `claude -p "/usage" --no-session-persistence` |

Si quieres entender qué significa cada barra y por qué la sesión no se reinicia a horas fijas, sigue con [los límites de 5 horas y semanal, explicados](/es/guias/limites-de-claude-explicados/).
