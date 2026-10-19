import requests
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
import time

API_BASE_URL = "https://api-sistema-vir.onrender.com/api"
ANIO_ACTUAL = 2026
PERIODO_ACTUAL = "2° Período"
URL_LOGIN = "https://9002.edusalta.gov.ar/login/index.php"
SEMANAS_ORDEN = ["S02", "S03", "S04", "S07", "S08", "S11", "S12", "Evaluaciones"]

modulo_input = input("Ingresá el número de Módulo a procesar (Ej: 1, 5, 6): ").strip()
MODULO_ACTUAL = int(modulo_input) if modulo_input.isdigit() else 6

print("1. Turismo | 2. Economía y Administración | 3. Ambas")
opcion = input("Elegí orientación: ").strip()
orientaciones = ["Economía y Administración"] if opcion == "2" else (["Turismo", "Economía y Administración"] if opcion == "3" else ["Turismo"])

driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()))

for orientacion in orientaciones:
    res_alumnos = requests.get(f"{API_BASE_URL}/alumnos_cursada", params={"modulo": MODULO_ACTUAL, "orientacion": orientacion, "anio": ANIO_ACTUAL, "periodo": PERIODO_ACTUAL}).json()
    actividades_directas = requests.get(f"{API_BASE_URL}/actividades", params={"modulo": MODULO_ACTUAL, "orientacion": orientacion}).json()
    url_calificaciones = requests.get(f"{API_BASE_URL}/config_curso", params={"modulo": MODULO_ACTUAL, "orientacion": orientacion}).json().get('url_calificaciones', 'https://9002.edusalta.gov.ar/grade/report/user/index.php?id=71')

    for alumno in res_alumnos:
        driver.get(URL_LOGIN)
        time.sleep(2.5)
        try:
            driver.find_element(By.ID, "username").send_keys(str(alumno['dni']).strip())
            driver.find_element(By.ID, "password").send_keys(str(alumno['contrasena_moodle']).strip())
            driver.find_element(By.ID, "loginbtn").click()
            time.sleep(3)
            
            datos_semanas = {sem: {"completas": [], "faltan": []} for sem in SEMANAS_ORDEN}
            driver.get(url_calificaciones)
            time.sleep(3)
            
            for fila_web in driver.find_elements(By.TAG_NAME, "tr"):
                t = fila_web.text
                if not t or "Total" in t: continue
                sem = next((s for s in SEMANAS_ORDEN if s in t), None)
                if sem:
                    lineas = t.split('\n')
                    nom = lineas[1] if (len(lineas) > 1 and ("CUESTIONARIO" in lineas[0] or "TAREA" in lineas[0])) else lineas[0]
                    mat = nom.split('_')[0].strip()
                    hecha = any(s in t for s in ["%", "✓", "✔", "✗", "✘"]) and "Vacío" not in t
                    lista_dest = datos_semanas[sem]["completas"] if hecha else datos_semanas[sem]["faltan"]
                    if mat not in lista_dest: lista_dest.append(mat)

            for act in actividades_directas:
                s, m, u = act['semana'], act['materia'], act['url_actividad']
                if m in datos_semanas[s]["completas"]: datos_semanas[s]["completas"].remove(m)
                if m in datos_semanas[s]["faltan"]: datos_semanas[s]["faltan"].remove(m)
                if u == 'Revisión_Manual':
                    datos_semanas[s]["completas"].append(f"{m} (Colaborativa)")
                    continue
                driver.get(u)
                time.sleep(2)
                txt = driver.find_element(By.TAG_NAME, "body").text
                if any(p in txt for p in ["Finalizado", "Enviado para calificar", "Archivos enviados", "Texto en línea", "Calificación", "Intentos: 1"]):
                    datos_semanas[s]["completas"].append(m)
                else:
                    datos_semanas[s]["faltan"].append(m)

            detalles = []
            for s in SEMANAS_ORDEN:
                c, f = len(datos_semanas[s]["completas"]), len(datos_semanas[s]["faltan"])
                if c > 0 or f > 0:
                    etiq = "Evaluaciones" if s == "Evaluaciones" else f"Semana {s.replace('S0', '').replace('S', '')}"
                    est = "COMPLETA" if f == 0 else ("No realizó nada" if c == 0 else f"Falta realizar {', '.join(datos_semanas[s]['faltan']).lower()}")
                    detalles.append(f"{etiq}: {est}")
            
            resumen = f"{alumno['nombre_completo'].upper()}: " + (" - ".join(detalles) if detalles else "Sin registros")
            requests.put(f"{API_BASE_URL}/seguimiento", json={"cursada_id": alumno['cursada_id'], "seguimiento_json": datos_semanas, "resumen_texto": resumen})
            driver.delete_all_cookies()
        except Exception as e:
            print("Error:", e)

driver.quit()