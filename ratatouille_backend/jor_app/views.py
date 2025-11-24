
from django.shortcuts import render
from .serializer import *
from .models import Recipe, Ingredient
from rest_framework import viewsets
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.decorators import action

# Create your views here.
@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_info(request):
    user = request.user
    return Response({
        "email": user.email,
        "username": user.username,
        "avatar": request.build_absolute_uri(user.avatar.url) if user.avatar else None
    })

class RecipeViewSet(viewsets.ModelViewSet):
    queryset = Recipe.objects.all().order_by('-created_at')
    serializer_class = RecipeSerializer

    @action(detail=False, methods=['get'])
    def by_category(self, request):
        category_name = request.query_params.get('category')
        if category_name:
            recipes = Recipe.objects.filter(category__name=category_name)
        else:
            recipes = Recipe.objects.all()
        serializer = self.get_serializer(recipes, many=True)
        return Response(serializer.data)

class CategoryViewSet(viewsets.ModelViewSet):
    queryset = Category.objects.all()
    serializer_class = CategorySerializer

@api_view(['POST'])
def search_recipes(request):
    """
    Хэрэглэгчийн орцуудыг авч тухайн орцуудыг агуулсан recipe-г буцаах
    """
    selected_ingredients = request.data.get('ingredients', [])
    
    if not selected_ingredients:
        return Response({"recipes": []})

    recipes = Recipe.objects.filter(
        ingredients__name__in=selected_ingredients
    ).distinct()

    # 🔥 Энд request дамжуулна
    serializer = RecipeSerializer(recipes, many=True, context={'request': request})
    return Response(serializer.data)

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

class IngredientViewSet(viewsets.ModelViewSet):
    queryset = Ingredient.objects.all()
    serializer_class = IngredientSerializer


class NutritionViewSet(viewsets.ModelViewSet):
    queryset = Nutrition.objects.all()
    serializer_class = NutritionSerializer
    # class RecipeViewSet(viewsets.ModelViewSet):
#     queryset = Recipe.objects.all()
#     serializer_class = RecipeSerializer


# class CookingStepViewSet(viewsets.ModelViewSet):
#     queryset = CookingStep.objects.all()
#     serializer_class = CookingStepSerializer
