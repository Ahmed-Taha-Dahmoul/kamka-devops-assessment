from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from notes.views import NoteViewSet
from django.http import JsonResponse

router = DefaultRouter()
router.register(r'notes', NoteViewSet)

# Healthcheck endpoint (Kamka IT explicitly requested health checks!)
def health_check(request):
    return JsonResponse({"status": "healthy"})

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include(router.urls)),
    path('health/', health_check), 
]