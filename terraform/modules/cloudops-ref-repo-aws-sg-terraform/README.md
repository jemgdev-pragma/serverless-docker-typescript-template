# Módulo Terraform: cloudops-ref-repo-aws-sg-terraform

## Descripción

Este módulo facilita la creación y gestión de Security Groups en AWS, permitiendo definir múltiples grupos de seguridad con sus respectivas reglas de ingress y egress de manera estructurada y siguiendo las mejores prácticas.

Consulta [CHANGELOG.md](./CHANGELOG.md) para la lista de cambios de cada versión. Recomendamos encarecidamente que en tu código fijes la versión exacta que estás utilizando para que tu infraestructura permanezca estable y actualices las versiones de manera sistemática para evitar sorpresas.

## Diagrama de Arquitectura

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                 │
│                         AWS VPC                                 │
│                                                                 │
│  ┌─────────────────┐         ┌─────────────────┐                │
│  │                 │         │                 │                │
│  │  Security Group │         │  Security Group │                │
│  │     (ALB)       │◄───────►│     (ECS)       │                │
│  │                 │         │                 │                │
│  └─────────────────┘         └────────┬────────┘                │
│          ▲                            │                         │
│          │                            │                         │
│          │                            ▼                         │
│  ┌───────┴───────┐         ┌─────────────────┐                │
│  │               │         │                 │                │
│  │    Internet   │         │  Security Group │                │
│  │               │         │     (RDS)       │                │
│  └───────────────┘         │                 │                │
│                            └─────────────────┘                │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

## Características

✅ Creación de múltiples grupos de seguridad usando mapas de objetos  
✅ Configuración flexible de reglas de ingress y egress  
✅ Soporte para referencias entre grupos de seguridad  
✅ Nomenclatura estandarizada para todos los recursos  
✅ Sistema de etiquetado completo y personalizable  
✅ Validaciones para garantizar configuraciones correctas  
✅ Documentación detallada y ejemplos de uso  
✅ Análisis de seguridad con Checkov  

## Estructura del Módulo

El módulo cuenta con la siguiente estructura:

```bash
cloudops-ref-repo-aws-sg-terraform/
├── sample/sg
│   ├── data.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── README.md
│   ├── terraform.tfvars.sample
│   └── variables.tf
├── security-reports
│   ├── checkov
│   │   ├── results.json
│   │   └── results.txt
│   └── SECURITY-REPORT.md
├── .gitignore
├── CHANGELOG.md
├── data.tf
├── locals.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── README.md
└── variables.tf
```

- Los archivos principales del módulo (`locals.tf`, `main.tf`, `outputs.tf`, `variables.tf`, `providers.tf`) se encuentran en el directorio raíz.
- `CHANGELOG.md` y `README.md` también están en el directorio raíz para fácil acceso.
- La carpeta `sample/` contiene un ejemplo de implementación del módulo.
- La carpeta `security-reports/` contiene los resultados del análisis de seguridad.

## Implementación y Configuración

### Requisitos Técnicos

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.31.0 |

### Provider Configuration

Este módulo requiere la configuración de un provider específico para el proyecto. Debe configurarse de la siguiente manera:

```hcl
# En providers.tf del consumidor
provider "aws" {
  alias = "alias01"
  region = "us-east-1"
  
  default_tags {
    tags = {
      environment = var.environment
      project     = var.project
      owner       = "cloudops"
      client      = var.client
      area        = "infrastructure"
      provisioned = "terraform"
      datatype    = "operational"
    }
  }
}

# En main.tf del consumidor
module "security_groups" {
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-sg-terraform.git?ref=v1.1.0"
  
  providers = {
    aws.project = aws.alias01
  }
  
  # Resto de la configuración...
}
```

### Configuración del Backend

Recomendamos configurar un backend remoto para almacenar el estado de Terraform:

```hcl
terraform {
  backend "s3" {
    bucket         = "nombre-bucket-terraform-state"
    key            = "ruta/al/estado/security-groups.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

### Convenciones de nomenclatura

Los nombres de los recursos siguen el estándar:
```
{client}-{project}-{environment}-sg-{service}-{application}
```

Por ejemplo: `cliente01-proyecto01-dev-sg-alb-web`

### Estrategia de Etiquetado

El sistema de etiquetado se implementa en tres niveles:

1. **Etiquetas Transversales**: Definidas a nivel del proveedor AWS usando `default_tags`
2. **Etiquetas Específicas del Módulo**: Definidas en la variable `additional_tags` del módulo
3. **Etiquetas Específicas del Recurso**: Definidas en la propiedad `additional_tags` de cada recurso en `sg_config`

### Recursos Gestionados

| Name | Type |
|------|------|
| [aws_security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

### Parámetros de Entrada

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_client"></a> [client](#input\_client) | Nombre del cliente | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Nombre del proyecto | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Entorno donde se desplegarán los recursos (dev, qa, pdn) | `string` | n/a | yes |
| <a name="input_additional_tags"></a> [additional_tags](#input\_additional_tags) | Etiquetas adicionales para todos los recursos creados por el módulo | `map(string)` | `{}` | no |
| <a name="input_sg_config"></a> [sg_config](#input\_sg_config) | Configuración de Security Groups | `map(object({...}))` | n/a | yes |

### Estructura de Configuración

La variable `sg_config` tiene la siguiente estructura:

```hcl
sg_config = {
  "sg1" = {
    description     = "Security group description"
    vpc_id          = "vpc-12345678"
    service         = "alb"
    application     = "web"
    additional_tags = { Owner = "Team1" }
    
    ingress = [
      {
        from_port       = 443
        to_port         = 443
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
        security_groups = []
        prefix_list_ids = []
        self            = false
        description     = "Allow HTTPS inbound"
      }
    ]
    
    egress = [
      {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
        prefix_list_ids = []
        security_groups = []
        self            = false
        description     = "Allow all outbound traffic"
      }
    ]
  }
}
```

### Valores de Salida

| Name | Description |
|------|-------------|
| <a name="output_sg_info"></a> [sg_info](#output\_sg_info) | Información de los grupos de seguridad creados, incluyendo ID y nombre |
| <a name="output_sg_ids"></a> [sg_ids](#output\_sg_ids) | Mapa de IDs de los grupos de seguridad creados, indexados por clave |
| <a name="output_sg_names"></a> [sg_names](#output\_sg_names) | Mapa de nombres de los grupos de seguridad creados, indexados por clave |
| <a name="output_sg_arns"></a> [sg_arns](#output\_sg_arns) | Mapa de ARNs de los grupos de seguridad creados, indexados por clave |

### Ejemplos de Uso

```hcl
module "security_groups" {
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-sg-terraform.git?ref=v1.1.0"
  
  providers = {
    aws.project = aws.project
  }

  # Common configuration 
  client      = "cliente01"
  project     = "proyecto01"
  environment = "dev"
  additional_tags = {
    cost-center = "cc-123"
    owner       = "team-infra"
  }

  # Security Group configuration
  sg_config = {
    "web" = {
      service     = "alb"
      application = "web"
      description = "Security group for web servers"
      vpc_id      = module.vpc.vpc_id
      additional_tags = {
        application-tier = "web"
      }

      ingress = [
        {
          from_port       = 80
          to_port         = 80
          protocol        = "tcp"
          cidr_blocks     = ["0.0.0.0/0"]
          security_groups = []
          prefix_list_ids = []
          self            = false
          description     = "Allow HTTP inbound"
        },
        {
          from_port       = 443
          to_port         = 443
          protocol        = "tcp"
          cidr_blocks     = ["0.0.0.0/0"]
          security_groups = []
          prefix_list_ids = []
          self            = false
          description     = "Allow HTTPS inbound"
        }
      ]

      egress = [
        {
          from_port       = 0
          to_port         = 0
          protocol        = "-1"
          cidr_blocks     = ["0.0.0.0/0"]
          prefix_list_ids = []
          security_groups = []
          self            = false
          description     = "Allow all outbound traffic"
        }
      ]
    },
    "app" = {
      service     = "ecs"
      application = "api"
      description = "Security group for application servers"
      vpc_id      = module.vpc.vpc_id
      additional_tags = {
        application-tier = "app"
      }

      ingress = [
        {
          from_port       = 8080
          to_port         = 8080
          protocol        = "tcp"
          cidr_blocks     = []
          security_groups = ["web"]
          prefix_list_ids = []
          self            = false
          description     = "Allow traffic from web security group"
        }
      ]

      egress = [
        {
          from_port       = 0
          to_port         = 0
          protocol        = "-1"
          cidr_blocks     = ["0.0.0.0/0"]
          prefix_list_ids = []
          security_groups = []
          self            = false
          description     = "Allow all outbound traffic"
        }
      ]
    }
  }
}
```

## Escenarios de Uso Comunes

### Grupo de seguridad para balanceador de carga público

```hcl
sg_config = {
  "alb" = {
    service     = "alb"
    application = "public"
    description = "Security group for public ALB"
    vpc_id      = module.vpc.vpc_id

    ingress = [
      {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
        security_groups = []
        prefix_list_ids = []
        self            = false
        description     = "Allow HTTP inbound"
      },
      {
        from_port       = 443
        to_port         = 443
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
        security_groups = []
        prefix_list_ids = []
        self            = false
        description     = "Allow HTTPS inbound"
      }
    ]

    egress = [
      {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
        prefix_list_ids = []
        security_groups = []
        self            = false
        description     = "Allow all outbound traffic"
      }
    ]
  }
}
```

### Grupo de seguridad para base de datos

```hcl
sg_config = {
  "db" = {
    service     = "rds"
    application = "postgres"
    description = "Security group for PostgreSQL database"
    vpc_id      = module.vpc.vpc_id

    ingress = [
      {
        from_port       = 5432
        to_port         = 5432
        protocol        = "tcp"
        cidr_blocks     = []
        security_groups = ["app"]
        prefix_list_ids = []
        self            = false
        description     = "Allow PostgreSQL traffic from app servers"
      }
    ]

    egress = [
      {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
        prefix_list_ids = []
        security_groups = []
        self            = false
        description     = "Allow all outbound traffic"
      }
    ]
  }
}
```

### Grupo de seguridad para clúster de ECS

```hcl
sg_config = {
  "ecs" = {
    service     = "ecs"
    application = "cluster"
    description = "Security group for ECS cluster"
    vpc_id      = module.vpc.vpc_id

    ingress = [
      {
        from_port       = 32768
        to_port         = 65535
        protocol        = "tcp"
        cidr_blocks     = []
        security_groups = ["alb"]
        prefix_list_ids = []
        self            = false
        description     = "Allow dynamic port mapping from ALB"
      }
    ]

    egress = [
      {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
        prefix_list_ids = []
        security_groups = []
        self            = false
        description     = "Allow all outbound traffic"
      }
    ]
  }
}
```

## Consideraciones Operativas

### Rendimiento y Escalabilidad

- AWS tiene un límite de 5 reglas por grupo de seguridad por defecto, que puede aumentarse contactando con AWS Support.
- Para aplicaciones con muchas reglas, considere agrupar reglas similares para evitar alcanzar los límites.
- Cada grupo de seguridad puede tener hasta 60 reglas de entrada y 60 reglas de salida (120 en total).
- Existe un límite de 500 grupos de seguridad por VPC (por defecto).

### Limitaciones y Restricciones

- Las reglas de grupos de seguridad son stateful, lo que significa que el tráfico permitido en una dirección automáticamente se permite en la dirección opuesta para esa conexión.
- No se pueden crear reglas circulares entre grupos de seguridad que puedan causar deadlocks.
- Las referencias a grupos de seguridad deben estar dentro de la misma VPC o VPCs con peering.

### Costos y Optimización

- Los grupos de seguridad no tienen costo directo, pero afectan a los recursos que los utilizan.
- Minimice el número de reglas para mejorar el rendimiento y la claridad.
- Considere usar prefix lists para agrupar rangos CIDR y simplificar la gestión.

### Recomendaciones de Implementación

- Utilice nombres descriptivos para las claves en `sg_config` para facilitar la referencia entre grupos.
- Agrupe los recursos por función para mantener las reglas claras y concisas.
- Evite usar `0.0.0.0/0` para reglas de ingress cuando sea posible, limitando el acceso a rangos de IP específicos.
- Documente claramente el propósito de cada regla en el campo `description`.
- Utilice referencias a grupos de seguridad en lugar de rangos CIDR cuando sea posible.

## Seguridad y Cumplimiento

### Consideraciones de seguridad

- Siga el principio de privilegio mínimo al definir reglas de grupos de seguridad.
- Evite abrir puertos innecesarios a Internet (0.0.0.0/0).
- Utilice referencias a otros grupos de seguridad en lugar de rangos CIDR cuando sea posible.
- Documente el propósito de cada regla con descripciones claras.
- Revise periódicamente las reglas para eliminar accesos innecesarios.

### Análisis de Seguridad

Este módulo ha sido analizado con [Checkov](https://www.checkov.io/) para detectar posibles vulnerabilidades y problemas de seguridad en la infraestructura como código.

#### Resultados del último escaneo

[![Checkov](https://img.shields.io/badge/Checkov-PASSED-success)](./security-reports/checkov/results.txt)

Puedes ver el reporte completo de seguridad en el [informe detallado](./security-reports/SECURITY-REPORT.md).

#### Resumen de hallazgos

| Severidad | Checkov | 
|-----------|---------|
| CRÍTICO   | 0       |
| ALTO      | 0       |
| MEDIO     | 0       |
| BAJO      | 0       |
| INFO      | 0       |
| **TOTAL** | 0       |

El análisis de seguridad no encontró problemas críticos, lo que indica que el módulo sigue las mejores prácticas de seguridad. Sin embargo, se recomienda revisar las advertencias relacionadas con la apertura de puertos 80 y 443 a 0.0.0.0/0 en los ejemplos, ya que esto podría representar un riesgo en ciertos escenarios.

### Mejores Prácticas Implementadas

- Validación de parámetros de entrada para evitar configuraciones incorrectas
- Nomenclatura estandarizada para todos los recursos
- Etiquetado completo para facilitar la gestión y el seguimiento de costos
- Separación de reglas de ingress y egress para mayor claridad
- Manejo seguro de referencias entre grupos de seguridad
- Descripción obligatoria para todas las reglas
- Validación de protocolos y puertos

### Lista de Verificación de Cumplimiento

- [x] Nomenclatura de recursos conforme al estándar
- [x] Etiquetas obligatorias aplicadas a todos los recursos
- [x] Validaciones para garantizar configuraciones correctas
- [x] Documentación detallada de parámetros y ejemplos
- [x] Soporte para referencias entre grupos de seguridad
- [x] Manejo adecuado de errores y casos límite
- [x] Análisis de seguridad con Checkov
- [x] Informe de seguridad detallado
- [x] Ejemplos de implementación completos

## Pruebas y Validación

### Pruebas Manuales

1. Implementar el ejemplo del directorio `sample`
2. Verificar que los grupos de seguridad se creen correctamente
3. Validar que los outputs contengan la información esperada
4. Probar los diferentes escenarios de uso
5. Verificar la integración con otros servicios AWS

```bash
cd sample/sg
terraform init
terraform plan
terraform apply
```

Verificar los recursos creados:

```bash
aws ec2 describe-security-groups --filters "Name=tag:Name,Values=cliente01-proyecto01-dev-sg-*"
```

## Observaciones

- Este módulo está diseñado para ser utilizado como parte de una arquitectura más amplia, donde los grupos de seguridad se integran con otros recursos como VPCs, instancias EC2, balanceadores de carga, etc.
- Para escenarios complejos con muchas reglas, considere dividir los grupos de seguridad por función para mantener la configuración manejable.
- Recuerde que los cambios en los grupos de seguridad se aplican inmediatamente, lo que puede afectar a las aplicaciones en ejecución si no se planifican adecuadamente.
- Las reglas de grupos de seguridad son stateful, lo que significa que no es necesario definir reglas de salida para el tráfico de respuesta de las conexiones entrantes permitidas.

> "Este módulo ha sido desarrollado siguiendo los estándares de Pragma CloudOps, garantizando una implementación segura, escalable y optimizada que cumple con todas las políticas de la organización. Pragma CloudOps recomienda revisar este código con su equipo de infraestructura antes de implementarlo en producción."
