from django.contrib import admin
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from jor_app.views import *
from django.conf import settings
from django.conf.urls.static import static

router = DefaultRouter()
router.register(r'recipes', RecipeViewSet)
router.register(r'categories', CategoryViewSet)
router.register(r'ingredients', IngredientViewSet)
router.register(r'users', UserViewSet)        # optional
router.register(r'nutritions', NutritionViewSet)  # optional

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include(router.urls)),

    path('api/search_recipes/', search_recipes),
    path('api/wishlist/my/', my_wishlist),
    path('api/wishlist/add/', add_wishlist),
    path('api/wishlist/remove/<int:pk>/', remove_wishlist),
    path('api/recipes/rate/', rate_recipe),

    path('auth/', include('djoser.urls')),
    path('auth/', include('djoser.urls.jwt')),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
